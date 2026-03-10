#!/bin/sh
# tmux-notify-build-list: emit tab-separated fzf input for tmux-notify-list.
# Output format per line: FILEPATH<TAB>HH:MM DD Mon  Title

DIR="$HOME/.local/share/tmux-notify"

ls -t "$DIR"/*.md 2>/dev/null | while IFS= read -r f; do
	base=$(basename "$f" .md)
	raw_ts=${base%%-*}
	fmt_ts=$(printf '%s' "$raw_ts" |
		sed 's/\(....\)\(..\)\(..\)T\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/')
	pretty_ts=$(date -d "$fmt_ts" '+%H:%M %d %b' 2>/dev/null ||
		date -r "$f" '+%H:%M %d %b' 2>/dev/null ||
		printf '??:??')
	title=$(head -1 "$f" | sed 's/^#\+[[:space:]]*//')
	[ -z "$title" ] && title="(no title)"
	printf '%s\t%s  %s\n' "$f" "$pretty_ts" "$title"
done
