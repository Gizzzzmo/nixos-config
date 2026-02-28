#!/bin/sh

# when TMUX environment variable is unset return an error
if [ -z "$TMUX" ]; then
    echo "Error: Not in tmux session."
    exit 1
fi

# delete all existing tmux environment variables
tmux showenv | perl -0 -ne 'print "$1\n" if /^([^=]+)=/' | while IFS= read -r line; do
    tmux setenv -u "$line"
done

# get the current shell's environment and put it into the current session's environment
env -0 | perl -0 -ne 'print "$1\n" if /^([^=]+)=/' | while IFS= read -r line; do
    eval var_value=\"\$"$line"\"

    tmux setenv "$line" "$var_value"
done
