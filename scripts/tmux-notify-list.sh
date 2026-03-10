#!/bin/sh
# tmux-notify-list: fzf-based notification browser.
# Launched from the M-n tmux keybind inside a display-popup.
#
# Keys:
#   enter   — view full notification with glow pager (q to return)
#   ctrl-x  — delete notification and reload list
#   ctrl-e  — open notification in $EDITOR
#   esc     — close popup

DIR="$HOME/.local/share/tmux-notify"
mkdir -p "$DIR"

HEADER="enter:view  ctrl-x:delete  ctrl-e:edit  esc:close"

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
	--bind="enter:execute(glow --pager {1})" \
	--bind="ctrl-x:execute-silent(rm -- {1})+reload(tmux-notify-build-list)" \
	--bind="ctrl-e:execute(nvim {1})" \
	--bind="esc:abort"
