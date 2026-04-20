#!/usr/bin/env bash

# When running inside an sshmux session, prefix the session name with the
# remote server so it's clear which machine the session belongs to.
if [ -n "$TMUX_SSH" ] && [ -n "$SSH_SERVER" ]; then
	host="${SSH_SERVER##*@}"
	session_name="${host}--$(basename "$(pwd)")"
else
	session_name=$(basename "$(pwd)")
fi

# create new session with session_name, if that fails, then there already exists a session with that name, so we just switch to that session
if ! tmux new-session -d -s "$session_name" 2>/dev/null; then
	if [ -z "$TMUX" ]; then
		tmux attach -t "$session_name"
	else
		tmux switch -t "$session_name"
	fi
	exit 0
fi

if [ -n "$TMUX_SSH" ]; then
	# Remote context: batch all setenv calls into a single SSH connection.
	env -0 | awk -v RS='\0' -v sn="$session_name" '
/=/ {
	i = index($0, "=")
	k = substr($0, 1, i - 1)
	v = substr($0, i + 1)
	gsub(/'\''/,  "'\''\\'\'''\''", v)
	print "tmux setenv -t " sn " " k " '\''" v "'\''"
}
' | ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" sh
else
	# Local context: call tmux directly in a loop.
	env -0 | awk -v RS='\0' -v ORS='\0' '
/=/ {
	i = index($0, "=")
	print substr($0, 1, i - 1) "\0" substr($0, i + 1)
}
' | while IFS= read -r -d '' var && IFS= read -r -d '' val; do
		tmux setenv -t "$session_name" "$var" "$val" </dev/null
	done
fi

tmux new-window -t "$session_name:"
tmux kill-window -t "$session_name":1
tmux new-window -t "$session_name":
tmux kill-window -t "$session_name":2

# if TMUX variable is not set attach, otherwise switch to the session
if [ -z "$TMUX" ] && [ -z "$TMUX_SSH" ]; then
	tmux attach -t "$session_name"
else
	tmux switch -t "$session_name"
fi
