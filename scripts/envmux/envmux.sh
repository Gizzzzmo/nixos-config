#!/bin/sh

session_name=$(basename $(pwd))

tmux -u new-session -d -s $session_name

env -0 | perl -0 -ne 'print "$1\n" if /^([^=]+)=/' | while IFS= read -r line; do
    tmux setenv -t $session_name $line "${!line}"
done

tmux new-window -t $session_name:
tmux kill-window -t $session_name:1
tmux new-window -t $session_name:
tmux kill-window -t $session_name:2

tmux attach -t $session_name
