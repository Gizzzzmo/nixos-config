#!/bin/sh
# tmux-notify-mode: toggle the notification display mode between active and silent.
# In silent mode new notifications are still saved but no log pane is created.
# Prints the new mode to stdout (displayed as a tmux status message via run-shell).

DIR="$HOME/.local/share/tmux-notify"
MODE_FILE="$DIR/.mode"
mkdir -p "$DIR"

current=$(cat "$MODE_FILE" 2>/dev/null || printf 'active')

if [ "$current" = "active" ]; then
	printf 'silent' >"$MODE_FILE"
	printf 'Notifications: SILENT'
else
	printf 'active' >"$MODE_FILE"
	printf 'Notifications: ACTIVE'
fi
