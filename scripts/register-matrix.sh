#!/bin/sh
# Register a new account on the self-hosted Matrix homeserver (Tuwunel).
# Usage: register-matrix.sh USERNAME [PASSWORD]
#
# Registration is gated by a token in /etc/tuwunel-registration-token
# (see services.matrix-tuwunel.settings.global.registration_token_file).
set -e

USERNAME="${1:?usage: $0 USERNAME [PASSWORD]}"
PASSWORD="${2:-}"

if [ -z "$PASSWORD" ]; then
	printf 'Password: '
	trap 'stty echo 2>/dev/null || true' 0
	stty -echo
	IFS= read -r PASSWORD
	stty echo
	trap - 0
	printf '\n'
fi

escape_json() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

TOKEN=$(sudo cat /etc/tuwunel-registration-token)
if [ -z "$TOKEN" ]; then
	echo "Could not read registration token from /etc/tuwunel-registration-token" >&2
	exit 1
fi

curl -sS -X POST https://matrix.jonbyr.com/_matrix/client/v3/register \
	-H 'Content-Type: application/json' \
	-d "{\"username\":\"$(escape_json "$USERNAME")\",\"password\":\"$(escape_json "$PASSWORD")\",\"auth\":{\"type\":\"m.login.registration_token\",\"token\":\"$TOKEN\"}}"