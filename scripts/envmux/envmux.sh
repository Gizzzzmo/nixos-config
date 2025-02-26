#!/bin/sh

tmux -u new-session -d -s $(basename $(pwd))

env | while IFS= read -r line; do
    value=${line#*=}
    name=${line%%=*}
    tmux setenv -t $(basename $(pwd)) $name $value
done

tmux attach -t $(basename $(pwd))
