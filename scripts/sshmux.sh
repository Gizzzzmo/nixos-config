#!/bin/sh
# Usage: sshmux.sh [-p port] [-d] [-s session-name] <user@host> [remote-dir]
# Creates a tmux session where all windows/panes SSH into the given server.
# If remote-dir is given, each shell starts in that directory on the server.
# Tmux environment variables are forwarded to each remote shell at pane
# creation time (via default-command), so updates to the tmux environment
# after session creation are picked up by newly opened panes as usual.
# Switches to the session if already inside tmux, otherwise attaches.
#
# A reverse SSH tunnel (remote:<RPORT> -> localhost:22) is maintained for the
# duration of the session via a dedicated tmux server (sshmux-tunnels). Tunnel
# windows are keyed by resolved IP and named <IP>|<RPORT>, so you can always
# look up which port to use when connecting back from the remote machine.
# Tunnel cleanup is manual: tmux -L sshmux-tunnels kill-window -t <IP>|<RPORT>
#
# Options:
#   -p port          SSH port to connect to
#   -d               Detached: create the session but do not switch/attach
#   -s session-name  Override the derived session name

PORT=""
DETACH=0
SESSION_OVERRIDE=""

while getopts "p:ds:" opt; do
	case "$opt" in
	p) PORT="$OPTARG" ;;
	d) DETACH=1 ;;
	s) SESSION_OVERRIDE="$OPTARG" ;;
	*)
		echo "Usage: $0 [-p port] [-d] [-s session-name] <user@host> [remote-dir]" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

SERVER="$1"
REMOTE_DIR="$2"

if [ -z "$SERVER" ]; then
	echo "Usage: $0 [-p port] [-d] [-s session-name] <user@host> [remote-dir]" >&2
	exit 1
fi

# Determine the session name: <host>-<basename-of-remote-dir>.
# Strip any user@ prefix from the server to get just the hostname.
HOST="${SERVER##*@}"

if [ -n "$REMOTE_DIR" ]; then
	# Directory was given explicitly — use its basename.
	REMOTE_BASE="$(basename "$REMOTE_DIR")"
else
	# Probe the remote default directory (the home directory).
	SSH_PROBE_FLAGS=""
	[ -n "$PORT" ] && SSH_PROBE_FLAGS="-p $PORT"
	REMOTE_BASE="$(ssh -o BatchMode=yes $SSH_PROBE_FLAGS "$SERVER" 'basename "$(pwd)"' 2>/dev/null)"
fi

if [ -n "$REMOTE_BASE" ]; then
	SESSION="$(printf '%s--%s' "$HOST" "$REMOTE_BASE" | tr '/' '_')"
else
	# Probe failed — fall back to just the hostname.
	SESSION="$HOST"
fi

# Allow the caller to override the derived session name.
[ -n "$SESSION_OVERRIDE" ] && SESSION="$SESSION_OVERRIDE"

# --- Reverse tunnel setup ---------------------------------------------------
#
# We use a dedicated tmux server (sshmux-tunnels) to host one persistent
# ssh -N process per remote IP. Each window is named <IP>:<RPORT> so the
# port is always visible and retrievable.
#
# We resolve the IP via `ssh -G` (respects ~/.ssh/config Host aliases) and
# then `getent hosts`, falling back to the raw hostname if resolution fails.

TMUX_TUNNELS="tmux -L sshmux-tunnels"

# Resolve the real hostname from ssh config, then to an IP.
SSH_HOSTNAME="$(ssh -G "$SERVER" 2>/dev/null | awk '/^hostname / {print $2; exit}')"
[ -z "$SSH_HOSTNAME" ] && SSH_HOSTNAME="$HOST"
REMOTE_IP="$(getent hosts "$SSH_HOSTNAME" 2>/dev/null | awk '{print $1; exit}')"
[ -z "$REMOTE_IP" ] && REMOTE_IP="$SSH_HOSTNAME"

# Check if a tunnel window for this IP already exists in the tunnel server.
# We use | as the separator between IP and port in the window name so that
# IPv6 addresses (which contain colons) are unambiguous.
EXISTING_WINDOW="$($TMUX_TUNNELS list-windows -F '#{window_name}' 2>/dev/null |
	grep "^${REMOTE_IP}|" | head -1)"

if [ -z "$EXISTING_WINDOW" ]; then
	# Pick a random port in the ephemeral-but-unregistered range 49152-65535.
	RPORT=$((49152 + ($(od -A n -N 2 -t u2 /dev/urandom | tr -d ' ') % 16383)))
	WINDOW_NAME="${REMOTE_IP}|${RPORT}"

	SSH_TUNNEL_FLAGS="-N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30"
	[ -n "$PORT" ] && SSH_TUNNEL_FLAGS="$SSH_TUNNEL_FLAGS -p $PORT"

	# Start the tunnel server if it isn't running yet, then open the window.
	if ! $TMUX_TUNNELS has-session 2>/dev/null; then
		$TMUX_TUNNELS new-session -d -s tunnels -n "$WINDOW_NAME" \
			"ssh $SSH_TUNNEL_FLAGS -R ${RPORT}:localhost:22 $SERVER"
	else
		$TMUX_TUNNELS new-window -n "$WINDOW_NAME" \
			"ssh $SSH_TUNNEL_FLAGS -R ${RPORT}:localhost:22 $SERVER"
	fi
else
	# Extract the port from the existing window name (<IP>|<RPORT>).
	RPORT="${EXISTING_WINDOW##*|}"
fi

# --- Main session setup -----------------------------------------------------

SSH_FLAGS="-t"
[ -n "$PORT" ] && SSH_FLAGS="$SSH_FLAGS -p $PORT"

if tmux has-session -t "$SESSION" 2>/dev/null; then
	# Session already exists — skip setup and go straight to attach/switch.
	:
else
	tmux new-session -d -s "$SESSION"

	# Write the awk program to a file to avoid quoting nesting in
	# default-command. The awk program turns `tmux show-environment` output
	# into safely single-quoted `export VAR='VALUE'` statements.
	AWK_FILE="/tmp/sshmux_${SESSION}.awk"
	cat >"$AWK_FILE" <<'EOF'
/^[^-]/ {
	i = index($0, "=")
	k = substr($0, 1, i - 1)
	v = substr($0, i + 1)
	gsub(/'/, "'\\''", v)
	print "export " k "='" v "'"
}
EOF

	# Capture the local PATH now, at session-creation time, so that a later
	# sourcemux (which overwrites the tmux PATH with the remote PATH) does
	# not cause ssh/awk/tmux to go missing when new panes are opened.
	# We single-quote-escape any single quotes in PATH just in case.
	LOCAL_PATH="$(printf '%s' "$PATH" | sed "s/'/'\\\\''/g")"

	# default-command is evaluated fresh at each new pane/window creation.
	# It must:
	#   1. Build the export snippet from the current tmux environment (locally).
	#   2. Pass it to the remote shell as part of the ssh RemoteCommand, so
	#      the exports happen on the server side, not the client side.
	#   3. After exporting, optionally cd to REMOTE_DIR, clear the terminal,
	#      and exec the login shell.
	if [ -n "$REMOTE_DIR" ]; then
		QUOTED_DIR="$(printf '%s' "$REMOTE_DIR" | sed "s/'/'\\\\''/g")"
		REMOTE_SUFFIX="cd '${QUOTED_DIR}' && clear && SSH_SERVER='$SERVER' SSH_PORT='$PORT' SSH_REVERSE_USER=$(whoami) SSH_REVERSE_PORT=$RPORT TMUX_SSH=\$TMUX \$SHELL -l"
	else
		REMOTE_SUFFIX="clear && SSH_SERVER='$SERVER' SSH_PORT='$PORT' SSH_REVERSE_USER=$(whoami) SSH_REVERSE_PORT=$RPORT TMUX_SSH=\$TMUX \$SHELL -l"
	fi

	tmux set-option -t "$SESSION" default-command \
		"PATH='${LOCAL_PATH}' ssh $SSH_FLAGS $SERVER -- sh -c \"\$(tmux show-environment | awk -f $AWK_FILE); $REMOTE_SUFFIX\""

	# Trigger the first window to run the same command.
	tmux send-keys -t "$SESSION" "$(tmux show-option -t "$SESSION" -v default-command)" Enter
fi

# Switch or attach unless -d was given.
if [ "$DETACH" -eq 1 ]; then
	exit 0
elif [ -n "$TMUX" ]; then
	tmux switch-client -t "$SESSION"
else
	tmux attach-session -t "$SESSION"
fi
