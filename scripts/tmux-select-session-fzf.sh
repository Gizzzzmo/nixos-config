#!/bin/sh

sessions=$(tmux list-sessions -F '#{session_name} #{session_last_attached}' | sort -t" " -rnk2 | awk '{ print $1; }')

if [ -n "$TMUX" ]; then
	sessions=$(echo "$sessions" | tail -n +2) # Exclude the current session from the list if we're already inside tmux
fi

selected=$(printf "%s\n%s\n%s" "$sessions" "$HOME" "$(zoxide query --list)" | fzf --reverse --prompt="Switch to session: " --height=100%)

echo "Selected session: $selected"

if [ -z "$selected" ]; then
	exit 1
fi

if tmux has-session -t "$selected" 2>/dev/null; then
	if [ -z "$TMUX" ]; then
		tmux attach-session -t "$selected"
	else
		tmux switch-client -t "$selected"
	fi
	exit 0
fi

# Go to the selected directory and execute envmux there
cd "$selected" && (direnv exec "$selected" envmux || exec envmux)
