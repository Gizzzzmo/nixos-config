#!/bin/sh
# tmux-notify-close: kill the tmux-notify-log pane in the current window.
# Called from the M-N keybind via run-shell.

TMUX_BIN=tmux

# The current window is passed as $1 by the keybind (#{window_id})
window="$1"

pane=$($TMUX_BIN list-panes -t "$window" -F "#{pane_id} #{pane_title}" 2>/dev/null |
	awk '/tmux-notify-log$/{print $1; exit}')

if [ -n "$pane" ]; then
	$TMUX_BIN kill-pane -t "$pane"
	msg="Notification pane closed"
else
	msg="No notification pane open"
fi

mode=$(cat "$HOME/.local/share/tmux-notify/.mode" 2>/dev/null || printf 'active')
if [ "$mode" = "silent" ]; then
	printf '%s  |  notifications: SILENT' "$msg"
else
	printf '%s  |  notifications: ACTIVE' "$msg"
fi
exit 0
