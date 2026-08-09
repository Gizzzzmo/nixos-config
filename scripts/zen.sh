set -eu

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zen"
state_file="$state_dir/state"
lock_dir="$state_dir/lock"
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/my-zen/config"
profile_bin="$HOME/.nix-profile/bin"
system_profile_bin="${ZEN_SYSTEM_PROFILE_BIN:-/run/current-system/sw/bin}"
at_bin="/run/wrappers/bin/at"
pkill_bin="/run/current-system/sw/bin/pkill"

mode=""
timed="0"
job=""
token=""
return_mode=""
declare -A directory_modes=()
declare -A configured_directories=()
declare -A configured_programs=()
programs=()
directories=()

usage() {
  printf '%s\n' 'Usage: zen {on|off} [DURATION] | zen status'
  exit 2
}

replace_link() {
  target="$1"
  destination="$2"
  temporary="$destination.new.$$"
  rm -f "$temporary"
  ln -s "$target" "$temporary"
  mv -Tf "$temporary" "$destination"
}

ensure_config() {
  if [ -f "$config_file" ]; then
    return
  fi

  mkdir -p "${config_file%/*}"
  umask 077
  cat > "$config_file" <<EOF
# One protected target per line.
# program hides the executable and terminates matching processes on zen on.
program firefox
# directory removes owner read, write, and execute permissions on zen on.
directory $HOME/Videos
EOF
  printf 'zen: created configuration at %s\n' "$config_file"
}

load_config() {
  programs=()
  directories=()
  configured_directories=()
  configured_programs=()

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '' | \#*) continue ;;
    esac

    if [[ "$line" =~ ^program[[:space:]]+([[:alnum:]_.+-]+)[[:space:]]*$ ]]; then
      program="${BASH_REMATCH[1]}"
      if [ -z "${configured_programs[$program]+x}" ]; then
        programs+=("$program")
        configured_programs["$program"]=1
      fi
    elif [[ "$line" =~ ^directory[[:space:]]+(/.*)$ ]]; then
      directory="${BASH_REMATCH[1]}"
      case "$directory" in
        *$'\t'* | *'|'*)
          printf 'zen: invalid directory in %s: %s\n' "$config_file" "$directory" >&2
          exit 2
          ;;
      esac
      if [ ! -d "$directory" ]; then
        printf 'zen: configured directory is unavailable: %s\n' "$directory" >&2
        exit 1
      fi
      if [ -z "${configured_directories[$directory]+x}" ]; then
        directories+=("$directory")
        configured_directories["$directory"]=1
      fi
    else
      printf 'zen: invalid configuration line in %s: %s\n' "$config_file" "$line" >&2
      exit 2
    fi
  done < "$config_file"
}

load_state() {
  mode="on"
  timed="0"
  job=""
  token=""
  return_mode=""
  directory_modes=()

  if [ -f "$state_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      if [[ "$line" == *=* ]]; then
        key="${line%%=*}"
        value="${line#*=}"
        path=""
      else
        IFS=$'\t' read -r key value path <<< "$line"
      fi
      case "$key" in
        mode) mode="$value" ;;
        timed) timed="$value" ;;
        job) job="$value" ;;
        token) token="$value" ;;
        return_mode) return_mode="$value" ;;
        directory_mode) directory_modes["$path"]="$value" ;;
        # Migrate the original single-directory state when upgrading in zen mode.
        videos_mode) [ -n "$value" ] && directory_modes["$HOME/Videos"]="$value" ;;
      esac
    done < "$state_file"
  fi
}

save_state() {
  temporary="$state_file.new.$$"
  umask 077
  {
    printf 'mode\t%s\n' "$mode"
    printf 'timed\t%s\n' "$timed"
    printf 'job\t%s\n' "$job"
    printf 'token\t%s\n' "$token"
    printf 'return_mode\t%s\n' "$return_mode"
    for directory in "${!directory_modes[@]}"; do
      printf 'directory_mode\t%s\t%s\n' "${directory_modes[$directory]}" "$directory"
    done
  } > "$temporary"
  mv -Tf "$temporary" "$state_file"
}

refresh_bin() {
  source_bin="$1"
  full_current="$2"
  restricted_current="$3"
  full_prefix="$4"
  restricted_prefix="$5"
  wrappers_bin="${ZEN_WRAPPERS_BIN:-/run/wrappers/bin}"

  if [ ! -d "$source_bin" ]; then
    printf 'zen: profile bin directory is unavailable: %s\n' "$source_bin" >&2
    exit 1
  fi

  full_bin="$state_dir/$full_prefix.$$.new"
  restricted_bin="$state_dir/$restricted_prefix.$$.new"
  mkdir "$full_bin"
  mkdir "$restricted_bin"
  for executable in "$source_bin"/*; do
    [ -e "$executable" ] || continue
    name="${executable##*/}"
    # Point setuid tools at /run/wrappers/bin so the mirror never shadows them.
    target="$executable"
    [ -e "$wrappers_bin/$name" ] && target="$wrappers_bin/$name"
    ln -s "$target" "$full_bin/$name"
    [ -n "${configured_programs[$name]+x}" ] && continue
    ln -s "$target" "$restricted_bin/$name"
  done
  replace_link "$full_bin" "$state_dir/$full_current"
  replace_link "$restricted_bin" "$state_dir/$restricted_current"
}

refresh_bins() {
  refresh_bin "$profile_bin" full-current restricted-current full-bin restricted-bin
  refresh_bin "$system_profile_bin" system-full-current system-restricted-current system-full-bin system-restricted-bin
}

restore_removed_directories() {
  for directory in "${!directory_modes[@]}"; do
    if [ -z "${configured_directories[$directory]+x}" ]; then
      chmod "${directory_modes[$directory]}" "$directory"
      unset 'directory_modes[$directory]'
    fi
  done
}

restrict_configured_directories() {
  for directory in "${directories[@]}"; do
    if [ -z "${directory_modes[$directory]+x}" ]; then
      directory_modes["$directory"]="$(stat -c %a "$directory")"
    fi
    chmod u-rwx "$directory"
  done
}

terminate_programs() {
  [ -x "$pkill_bin" ] || {
    printf 'zen: pkill is unavailable at %s\n' "$pkill_bin" >&2
    exit 1
  }

  for program in "${programs[@]}"; do
    echo "$program"
    if "$pkill_bin" "-9" -- "$program"; then
      :
    elif [ "$?" -ne 1 ]; then
      printf 'zen: failed to terminate %s\n' "$program" >&2
      exit 1
    fi
  done
}

enable_zen() {
  kill_programs="$1"
  restore_removed_directories
  restrict_configured_directories
  replace_link restricted-current "$state_dir/bin"
  replace_link system-restricted-current "$state_dir/system-bin"
  mode="on"
  [ "$kill_programs" = 1 ] && terminate_programs
  true
}

disable_zen() {
  for directory in "${!directory_modes[@]}"; do
    chmod "${directory_modes[$directory]}" "$directory"
  done
  directory_modes=()
  replace_link full-current "$state_dir/bin"
  replace_link system-full-current "$state_dir/system-bin"
  mode="off"
}

transition() {
  case "$1" in
    on) enable_zen "${2:-0}" ;;
    off) disable_zen ;;
    *) printf 'zen: invalid mode: %s\n' "$1" >&2; exit 2 ;;
  esac
}

schedule_return() {
  duration="$1"
  if ! [[ "$duration" =~ ^([1-9][0-9]*)([smhd])$ ]]; then
    printf 'zen: duration must be a positive number followed by s, m, h, or d\n' >&2
    exit 2
  fi
  amount="${BASH_REMATCH[1]}"
  unit="${BASH_REMATCH[2]}"
  case "$unit" in
    s) seconds="$amount" ;;
    m) seconds=$((amount * 60)) ;;
    h) seconds=$((amount * 3600)) ;;
    d) seconds=$((amount * 86400)) ;;
    *) usage ;;
  esac

  [ -x "$at_bin" ] || {
    printf 'zen: at wrapper is unavailable at %s\n' "$at_bin" >&2
    exit 1
  }

  due_time="$(date -d "@$(( $(date +%s) + seconds ))" +%Y%m%d%H%M.%S)"
  token="$(date +%s)-$$"
  self="$(readlink -f "$0")"
  at_output="$("$at_bin" -t "$due_time" 2>&1 <<EOF
"$self" --expire "$token" "$return_mode"
EOF
)"
  case "$at_output" in
    *job\ *) job="${at_output#*job }"; job="${job%% *}" ;;
    *)
      printf 'zen: failed to schedule reactivation: %s\n' "$at_output" >&2
      exit 1
      ;;
  esac
}

status() {
  if [ "$timed" = 1 ]; then
    printf 'zen is %s temporarily; it will return to %s (at job %s)\n' "$mode" "$return_mode" "$job"
  else
    printf 'zen is %s indefinitely\n' "$mode"
  fi
}

mkdir -p "$state_dir"
if ! mkdir "$lock_dir" 2>/dev/null; then
  printf '%s\n' 'zen: another zen command is already running' >&2
  exit 1
fi
trap 'rmdir "$lock_dir"' EXIT
ensure_config
load_config
load_state

case "${1:-}" in
  --refresh)
    [ "$#" -eq 1 ] || usage
    refresh_bins
    transition "$mode"
    save_state
    ;;
  --expire)
    if [ "$#" -eq 1 ]; then
      [ "$timed" = 1 ] || {
        printf '%s\n' 'zen: no timed transition is pending' >&2
        exit 1
      }
    else
      [ "$#" -eq 3 ] || usage
      [ "$timed" = 1 ] && [ "$2" = "$token" ] && [ "$3" = "$return_mode" ] || exit 0
    fi
    timed="0"
    job=""
    token=""
    transition "$return_mode" 1
    return_mode=""
    save_state
    ;;
  status)
    [ "$#" -eq 1 ] || usage
    status
    ;;
  on|off)
    desired_mode="$1"
    [ "$#" -le 2 ] || usage
    if [ "$timed" = 1 ]; then
      printf '%s\n' 'zen: a timed transition is pending; wait for it to expire' >&2
      exit 1
    fi
    if [ "$mode" = "$desired_mode" ]; then
      printf 'zen: already %s\n' "$mode" >&2
      exit 1
    fi
    if [ "$#" -eq 2 ]; then
      timed="1"
      return_mode="$mode"
      schedule_return "$2"
    fi
    kill_programs=0
    [ "$desired_mode" = on ] && kill_programs=1
    transition "$desired_mode" "$kill_programs"
    save_state
    ;;
  *) usage ;;
esac
