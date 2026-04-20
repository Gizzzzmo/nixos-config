#!/bin/sh
# tmux-notify-server: listens on TCP 9896, receives markdown notifications,
# writes them to ~/.local/share/tmux-notify/, and (unless in silent mode)
# appends a log line to a persistent bottom pane in the most-active tmux window.
#
# Nix substitution placeholders (replaced at build time in jonas-home.nix):
SOCAT=socat
TMUX_BIN=tmux

NOTIFY_DIR="$HOME/.local/share/tmux-notify"
MODE_FILE="$NOTIFY_DIR/.mode"
PORT=9876

mkdir -p "$NOTIFY_DIR"

# ── per-connection handler ────────────────────────────────────────────────────
# When socat re-invokes this script per connection it passes --handle.
if [ "$1" = "--handle" ]; then
	# Read the full notification body from stdin into a temp file
	tmp=$(mktemp)
	cat >"$tmp"

	# Parse title from first line: strip leading "# "
	first_line=$(head -1 "$tmp")
	title=$(printf '%s' "$first_line" | sed 's/^#\+[[:space:]]*//')
	[ -z "$title" ] && title="Notification"

	# Build filename: timestamp + slug
	ts=$(date +%Y%m%dT%H%M%S)
	slug=$(printf '%s' "$title" |
		tr '[:upper:]' '[:lower:]' |
		sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//')
	[ -z "$slug" ] && slug="notification"
	dest="$NOTIFY_DIR/${ts}-${slug}.md"

	cp "$tmp" "$dest"
	rm -f "$tmp"

	# Check mode
	mode=$(cat "$MODE_FILE" 2>/dev/null || printf 'active')
	[ "$mode" = "silent" ] && exit 0

	# Locate the tmux socket — the systemd service has no $TMUX env var,
	# so we must address the server explicitly via -S.
	uid=$(id -u)
	tmux_socket="/run/user/${uid}/tmux-${uid}/default"
	[ ! -S "$tmux_socket" ] && exit 0
	TMUX_BIN="$TMUX_BIN -S $tmux_socket"

	# Find the active window of the most-recently-active tmux client
	session=$($TMUX_BIN list-clients -F "#{client_activity} #{client_session}" 2>/dev/null |
		sort -rn | head -1 | awk '{print $2}')
	[ -z "$session" ] && exit 0
	window=$($TMUX_BIN list-windows -t "$session" -F "#{window_active} #{window_id}" 2>/dev/null |
		awk '/^1 /{print $2; exit}')
	[ -z "$window" ] && exit 0

	# Look for an existing log pane in this window
	pane=$($TMUX_BIN list-panes -t "$window" -F "#{pane_id} #{pane_title}" 2>/dev/null |
		awk '/tmux-notify-log$/{print $1; exit}')

	if [ -z "$pane" ]; then
		# Create a dumb (no-command) bottom pane
		pane=$($TMUX_BIN split-window -v -l 6 -d -t "$window" -P -F "#{pane_id}" '' 2>/dev/null)
		[ -z "$pane" ] && exit 0
		$TMUX_BIN select-pane -t "$pane" -T "tmux-notify-log"
		printf '\033[90m─── tmux-notify ───────────────────────────────────\033[0m\n' |
			$TMUX_BIN display-message -I -t "$pane" 2>/dev/null
	fi

	# Append log line: HH:MM  title
	time_str=$(date +%H:%M)
	printf '\033[90m%s\033[0m  %s\n' "$time_str" "$title" |
		$TMUX_BIN display-message -I -t "$pane" 2>/dev/null

	exit 0
fi

# ── main server loop ──────────────────────────────────────────────────────────
exec $SOCAT TCP-LISTEN:$PORT,reuseaddr,fork \
	EXEC:"$0 --handle"
