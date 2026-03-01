#!/bin/sh

sessions=$(tmux list-sessions -F '#{session_name} #{session_last_attached}' | sort -t" " -rnk2 | awk '{ print $1; }')

if [ -n "$TMUX" ]; then
	sessions=$(echo "$sessions" | tail -n +2) # Exclude the current session from the list if we're already inside tmux
fi

# Get a list of other directories
other_dirs=$(zoxide query --list)
other_dirs=$(printf "%s\n%s" "$HOME" "$other_dirs")

# filter out directories whose basename matches any session name, to avoid cluttering the list with irrelevant entries
filtered_dirs=$(echo "$other_dirs" | awk -v sessions="$sessions" 'BEGIN{split(sessions,a,"\
"); for(i in a) sess[a[i]]=1} {base=$0; sub(/.*\//,"",base); if(!(base in sess)) print}')

all_options=$(printf "%s\n%s" "$sessions" "$filtered_dirs")

selected=$(echo "$all_options" | fzf --reverse --prompt="Switch to session: " --height=100%)

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
