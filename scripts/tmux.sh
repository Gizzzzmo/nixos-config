#!/bin/sh

REAL_TMUX=tmux

# If TMUX_SSH is not set we are not inside an sshmux session — just run tmux.
if [ -z "$TMUX_SSH" ]; then
	exec $REAL_TMUX "$@"
fi

# --- Scan for tmux pre-command flags ----------------------------------------
#
# tmux accepts global flags before the command name:
#   boolean:      -2 -C -D -h -l -N -u -V -v
#   value-taking: -c -f -L -S -T
#
# If any are present the user is targeting a specific socket or doing something
# low-level — fall through to the real local tmux binary unchanged.

has_precmd_flags=0
i=0
for arg in "$@"; do
	# Stop scanning once we've passed all leading flags.
	case "$arg" in
	-[2CDhlNuVv])
		has_precmd_flags=1
		;;
	-[cfLST])
		has_precmd_flags=1
		# The next argument is the value — skip it by bumping i,
		# but since we're in a for loop we can't skip cleanly; the
		# flag detection is enough to bail out.
		;;
	-[cfLST]*)
		# Value attached directly, e.g. -Smysocket
		has_precmd_flags=1
		;;
	-*)
		# Unknown flag before the command — let real tmux handle it.
		has_precmd_flags=1
		;;
	*)
		# First non-flag argument is the command name — stop scanning.
		break
		;;
	esac
done

if [ "$has_precmd_flags" -eq 1 ]; then
	exec $REAL_TMUX "$@"
fi

# --- Validate reverse tunnel environment ------------------------------------

if [ -z "$SSH_REVERSE_PORT" ] || [ -z "$SSH_REVERSE_USER" ]; then
	echo "tmux: SSH_REVERSE_PORT and SSH_REVERSE_USER must be set." >&2
	exit 1
fi

# --- Identify the command ---------------------------------------------------
# With no pre-command flags, the first argument is the command (or absent).

CMD="${1:-new-session}"

# --- Dispatch ---------------------------------------------------------------

case "$CMD" in
new-session | new)
	# If we are already inside a tmux session and -d was not given,
	# replicate tmux's own behaviour: warn and refuse to nest.
	if [ -n "$TMUX" ]; then
		# Check if -d is among the arguments.
		detach=0
		for arg in "$@"; do
			case "$arg" in
			-*d*)
				detach=1
				break
				;;
			esac
		done
		if [ "$detach" -eq 0 ]; then
			echo "tmux: sessions should be nested with care, unset \$TMUX to force" >&2
			exit 1
		fi
	fi

	# Parse the new-session arguments we care about:
	#   -c start-directory  → remote directory for sshmux
	#   -s session-name     → forwarded to sshmux -s
	#   -d                  → forwarded to sshmux -d
	# Everything else is silently ignored.
	dir=""
	session_name=""
	detach_flag=""
	shift # drop the command name (or "new-session")

	while [ $# -gt 0 ]; do
		case "$1" in
		-c)
			dir="$2"
			shift 2
			;;
		-c*)
			dir="${1#-c}"
			shift
			;;
		-s)
			session_name="$2"
			shift 2
			;;
		-s*)
			session_name="${1#-s}"
			shift
			;;
		-d)
			detach_flag="-d"
			shift
			;;
		-[AdDEPXn]) shift 2 2>/dev/null || shift ;;  # known value-taking flags to skip
		-[FntxyeEf]) shift 2 2>/dev/null || shift ;; # more value-taking flags
		--)
			shift
			break
			;;
		-*) shift ;; # ignore other flags
		*) break ;;  # shell-command starts here — ignore
		esac
	done

	# Use $PWD on the remote as the directory if -c was not given.
	[ -z "$dir" ] && dir="$PWD"

	# Build the sshmux.sh call via the reverse tunnel.
	# sshmux is always called with -d here: attaching is the
	# responsibility of the caller (tmux switch-client / attach-session).
	ssh_cmd="sshmux.sh -d"
	[ -n "$SSH_PORT" ] && ssh_cmd="$ssh_cmd -p '$SSH_PORT'"
	[ -n "$session_name" ] && ssh_cmd="$ssh_cmd -s '$session_name'"
	ssh_cmd="$ssh_cmd '$SSH_SERVER' '$dir'"

	ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" "$ssh_cmd"

	# If the caller did not pass -d, switch to the new session now.
	if [ -z "$detach_flag" ]; then
		# We need the session name. If overridden, use it directly;
		# otherwise ask the local tmux for the last created session.
		if [ -n "$session_name" ]; then
			target="$session_name"
		else
			target="$(ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" \
				"tmux list-sessions -F '#{session_name}' | tail -1")"
		fi
		[ -n "$target" ] &&
			ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" \
				"tmux switch-client -t '=$target'"
	fi
	;;

*)
	# All other commands: forward directly to the local tmux.
	ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" tmux "$@"
	;;
esac
