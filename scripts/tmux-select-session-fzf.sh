#!/bin/sh

sessions=$(tmux list-sessions -F '#{session_name} #{session_last_attached}' | sort -t" " -rnk2 | awk '{ print $1; }')

# Build a query that excludes tmux sessions from the zoxide results.
grep_query=$(printf '%s\n' "$sessions" | awk \
	'/./ {
         if (query != "")
             query = query "|"
         query = query $0
     }
     END {
         if (query != "")
             print "(" query ")$"
         else
             print "a^"
     }')

if [ -n "$TMUX" ]; then
	sessions=$(echo "$sessions" | tail -n +2) # Exclude the current session from the list if we're already inside tmux
fi

selected=$(
	{
		# Keep tmux sessions ahead of zoxide entries, while preserving their MRU order.
		printf '%s\n' "$sessions" | awk 'NF { print (1000000000 - NR) "\t" $0 }'
		printf '99999999\t%s\n' "$HOME" | grep -v -E "$grep_query"
		zoxide query --list --score | grep -v -E "$grep_query" | awk '{ score = $1; $1 = ""; sub(/^ /, ""); print score "\t" $0 }'
	} | fzf --delimiter="$(printf '\t')" --with-nth=2.. --accept-nth=2.. --tiebreak=index --reverse --prompt="Switch to session: " --height=100%
)

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
