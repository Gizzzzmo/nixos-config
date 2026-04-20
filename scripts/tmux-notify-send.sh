#!/bin/sh
# tmux-notify-send: pipe a markdown notification to the tmux-notify-server.
# Reads from stdin (or a file path given as first argument).
#
# Usage:
#   echo -e "# Hello\n\nSome message" | tmux-notify-send
#   tmux-notify-send < alert.md
#   tmux-notify-send /path/to/alert.md

PORT=9876

if [ -n "$1" ]; then
	nc -q1 127.0.0.1 "$PORT" <"$1"
else
	nc -q1 127.0.0.1 "$PORT"
fi
