#!/usr/bin/env bash

if [ -z "$TMUX" ] && [ -z "$TMUX_SSH" ]; then
	echo "Error: Not in a tmux session." >&2
	exit 1
fi

if [ -n "$TMUX_SSH" ]; then
	# Remote context: all tmux calls go over SSH. Batch everything into a
	# single connection to avoid one round-trip per variable.

	# Build a shell script that clears existing vars and sets new ones,
	# then pipe it to a single ssh session.
	{
		# Emit: tmux setenv -u VAR  for each currently-set var.
		tmux showenv </dev/null | awk -F= '/^[^-]/ { print "tmux setenv -u " $1 }'

		# Emit: tmux setenv VAR VALUE  for each current shell env var.
		# Values are single-quoted with internal single-quotes escaped.
		env -0 | awk -v RS='\0' '
/=/ {
	i = index($0, "=")
	k = substr($0, 1, i - 1)
	v = substr($0, i + 1)
	gsub(/'\''/,  "'\''\\'\'''\''", v)
	print "tmux setenv " k " '\''" v "'\''"
}
'
	} | ssh -p "$SSH_REVERSE_PORT" "$SSH_REVERSE_USER@localhost" sh
else
	# Local context: call tmux directly in a loop.

	# Clear all existing session environment variables.
	tmux showenv | awk -F= '/^[^-]/ { print $1 }' | while IFS= read -r var; do
		tmux setenv -u "$var" </dev/null
	done

	# Copy the current shell environment into the tmux session environment.
	# env -0 uses null delimiters so values containing newlines are handled safely.
	env -0 | awk -v RS='\0' -v ORS='\0' '
/=/ {
	i = index($0, "=")
	print substr($0, 1, i - 1) "\0" substr($0, i + 1)
}
' | while IFS= read -r -d '' var && IFS= read -r -d '' val; do
		tmux setenv "$var" "$val" </dev/null
	done
fi
