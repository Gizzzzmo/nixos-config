#!/bin/sh

session_name=$(basename "$(pwd)")

# create new session with session_name, if that fails, then there already exists a session with that name, so we just switch to that session
tmux new-session -d -s "$session_name" 2>/dev/null || (tmux switch -t "$session_name" && exit)

env -0 | perl -0 -ne 'print "$1\n" if /^([^=]+)=/' | while IFS= read -r line; do
    eval var_value=\"\$"$line"\"

    tmux setenv -t "$session_name" "$line" "$var_value"
done

tmux new-window -t "$session_name:"
tmux kill-window -t "$session_name":1
tmux new-window -t "$session_name":
tmux kill-window -t "$session_name":2

# if TMUX variable is not set attach, otherwise switch to the session
if [ -z "$TMUX" ]; then
    tmux attach -t "$session_name"
else
    tmux switch -t "$session_name"
fi
