#!/bin/sh
# tmux-notify-list: fzf-based notification browser.
# Launched from the M-n tmux keybind inside a display-popup.
#
# Keys:
#   enter   — view full notification with glow pager (q to return)
#   ctrl-x  — delete notification and reload list
#   ctrl-e  — open notification in $EDITOR
#   ctrl-u  — pick and open a URL from the notification
#   esc     — close popup

open_url() {
	file="$1"
	if [ -z "$file" ]; then
		file="$TMUX_NOTIFY_SOURCE"
	fi
	[ -n "$file" ] || return 1
	url="$(grep -oE 'https?://[^[:space:]>)"]+' -- "$file" | fzf --prompt='Open URL > ')" || return 0
	[ -n "$url" ] || return 0
	nohup xdg-open "$url" >/dev/null 2>&1 </dev/null &
}

view_notification() {
	lesskey_src="$(mktemp "${TMPDIR:-/tmp}/tmux-notify-lesskey.XXXXXX")" || return 1
	rendered="$(mktemp "${TMPDIR:-/tmp}/tmux-notify-rendered.XXXXXX")" || {
		rm -f -- "$lesskey_src"
		return 1
	}
	printf '#command\n^U visual\n\n' >"$lesskey_src"
	script -qec "glow --style=dark \"$1\"" /dev/null >"$rendered"
	TMUX_NOTIFY_SOURCE="$1" VISUAL="$0 open-url-editor" LESSKEYIN="$lesskey_src" less -R "$rendered"
	rm -f -- "$rendered"
	rm -f -- "$lesskey_src"
}

case "$1" in
open-url)
	open_url "$2"
	exit $?
	;;
open-url-editor)
	open_url
	exit $?
	;;
view)
	view_notification "$2"
	exit $?
	;;
esac

DIR="$HOME/.local/share/tmux-notify"
mkdir -p "$DIR"

HEADER="enter:view  ctrl-x:delete  ctrl-e:edit  ctrl-u:open-url  esc:close"

tmux-notify-build-list | fzf \
	--ansi \
	--reverse \
	--no-sort \
	--delimiter='	' \
	--with-nth=2 \
	--prompt="Notifications > " \
	--header="$HEADER" \
	--preview="script -qec 'glow --style=dark {1}' /dev/null" \
	--preview-window="right:60%:wrap" \
	--bind="enter:execute($0 view {1})" \
	--bind="ctrl-x:execute-silent(rm -- {1})+reload(tmux-notify-build-list)" \
	--bind="ctrl-e:execute(nvim {1})" \
	--bind="ctrl-u:execute($0 open-url {1})" \
	--bind="esc:abort"
