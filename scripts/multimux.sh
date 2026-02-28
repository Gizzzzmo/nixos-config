#!/bin/sh

# Create a new window with a pane for every argument, and for every pane change directory into the respective argument.
# If no arguments are given it will treat all non-hidden subdirectories of the current working directory as arguments.

tmux new-window -n multi_shell

if [ $# -eq 0 ]; then
    dirs=$(find . -maxdepth 1 -mindepth 1 -type d -not -path '*/[@.]*')
    num=$(echo "$dirs" | wc -l)
    counter=1
    echo "$dirs" | while IFS= read -r line; do
        tmux send-keys -t multi_shell.$counter "cd $line" Enter
        tmux send-keys -t multi_shell.$counter "clear" Enter
        # split the window unless this is the last argument
        if [ $counter -lt "$num" ]; then
            tmux split-window -t multi_shell -h
        fi
        counter=$((counter + 1))
    done

else
    counter=1
    for var in "$@"; do
        tmux send-keys -t multi_shell.$counter "cd $var" Enter
        tmux send-keys -t multi_shell.$counter "clear" Enter
        # split the window unless this is the last argument
        if [ $counter -lt $# ]; then
            tmux split-window -t multi_shell -h
        fi
        counter=$((counter + 1))
    done
fi

tmux select-layout even-horizontal
tmux set synchronize-panes on
