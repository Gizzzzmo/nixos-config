#!/bin/sh
# cmus-control.sh — control cmus locally or on a remote host via SSH
#
# Subcommands:
#   play-pause      toggle playback on the active target
#   next            skip to next track on the active target
#   prev            skip to previous track on the active target
#   cycle-target    advance to the next target in ~/.config/cmus/targets
#
# Target list: ~/.config/cmus/targets
#   One target per line. Use "local" for the local machine,
#   or a SSH host (e.g. "jonas@thinkpad") for remote machines.
#
# Active target state: ~/.local/state/cmus-target

TARGETS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cmus/targets"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/cmus-target"

# Ensure the targets file exists with a sensible default
if [ ! -f "$TARGETS_FILE" ]; then
	mkdir -p "$(dirname "$TARGETS_FILE")"
	echo "local" >"$TARGETS_FILE"
fi

# Read the active target (default to "local" if state file is missing or empty)
if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
	TARGET="$(cat "$STATE_FILE")"
else
	TARGET="$(head -n1 "$TARGETS_FILE")"
fi

# Run a cmus-remote command on the active target
run_cmus_remote() {
	if [ "$TARGET" = "local" ]; then
		cmus-remote "$@"
	else
		ssh -o BatchMode=yes -o ConnectTimeout=3 "$TARGET" cmus-remote "$@"
	fi
}

CMD="$1"

case "$CMD" in
play-pause)
	run_cmus_remote -u
	;;
next)
	run_cmus_remote -n
	;;
prev)
	run_cmus_remote -p
	;;
cycle-target)
	# Read all non-empty, non-comment lines from the targets file
	TARGETS="$(grep -v '^\s*#' "$TARGETS_FILE" | grep -v '^\s*$')"
	COUNT="$(printf '%s\n' "$TARGETS" | wc -l)"

	if [ "$COUNT" -le 1 ]; then
		if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
			hyprctl notify 2 5000 'rgb(ff0000)' "cmus Target: Only one target available, cannot cycle"
		fi
		exit 0
	fi

	# Find the index of the current target (1-based)
	IDX=0
	I=0
	while IFS= read -r LINE; do
		I=$((I + 1))
		if [ "$LINE" = "$TARGET" ]; then
			IDX=$I
		fi
	done <<EOF
$TARGETS
EOF

	# Advance to the next target (wrap around)
	NEXT_IDX=$(((IDX % COUNT) + 1))
	NEW_TARGET="$(printf '%s\n' "$TARGETS" | sed -n "${NEXT_IDX}p")"

	# Persist the new target
	mkdir -p "$(dirname "$STATE_FILE")"
	printf '%s' "$NEW_TARGET" >"$STATE_FILE"

	if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
		hyprctl notify 2 5000 'rgb(ff0000)' "cmus Target: ${NEW_TARGET}"
	fi
	;;
*)
	echo "Usage: cmus-control {play-pause|next|prev|cycle-target}" >&2
	exit 1
	;;
esac
