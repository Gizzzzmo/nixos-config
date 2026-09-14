#!/usr/bin/env bash
# Recover the SSL 2 Mk II output device when PipeWire fails to create its
# sink node, leaving the interface input-only (e.g. missing in wiremix).
#
# Root cause: apps using cpal/ALSA (e.g. handy) can hold the interface's
# playback PCM open directly, bypassing PipeWire. If WirePlumber tries to
# (re)create the card's nodes at that moment, sink creation fails with
# EBUSY and is never retried.
#
# Usage: fix-ssl-sink.sh
#   1. Kills handy if it is holding the playback PCM
#   2. Toggles the card profile off -> pro-audio to force node re-creation
#   3. Verifies the sink node exists afterwards

set -euo pipefail

CARD_NAME="SSL 2 Mk II"
DEVICE_MATCH="Solid_State_Logic_SSL_2_Mk_II"

# --- resolve ALSA card number -------------------------------------------------
CARD=$(awk -v n="$CARD_NAME" '$0 ~ "- "n"$" {print $1}' /proc/asound/cards)
if [ -z "$CARD" ]; then
	echo "Error: card '$CARD_NAME' not found in /proc/asound/cards (plugged in?)"
	exit 1
fi
echo "Found $CARD_NAME on ALSA card $CARD"

# --- free the playback PCM if something (handy) is holding it -----------------
HW_PARAMS="/proc/asound/card$CARD/pcm0p/sub0/hw_params"
STATE=$(cat "$HW_PARAMS" 2>/dev/null || echo closed)
if [ "$STATE" != "closed" ]; then
	HOLDER=$(lsof -t "/dev/snd/pcmC${CARD}D0p" 2>/dev/null | head -1 || true)
	if [ -n "$HOLDER" ]; then
		echo "Playback PCM is held by PID $HOLDER ($(ps -o comm= -p "$HOLDER" 2>/dev/null || echo '?'))"
	fi
	echo "Killing handy (cpal/ALSA grabs the raw playback device)..."
	pkill -f handy-wrapped || true
	for _ in $(seq 1 10); do
		STATE=$(cat "$HW_PARAMS" 2>/dev/null || echo closed)
		[ "$STATE" = "closed" ] && break
		sleep 0.5
	done
	if [ "$STATE" != "closed" ]; then
		echo "Error: playback PCM still busy (state: $STATE); close the other app and retry."
		exit 1
	fi
fi
echo "Playback PCM is free"

# --- resolve PipeWire device id + pro-audio profile index ----------------------
DUMP=$(pw-dump)
DEV=$(jq -r --arg m "$DEVICE_MATCH" '
	.[] | select(.type=="PipeWire:Interface:Device")
	| select(.info.props["device.name"] // "" | contains($m)) | .id' <<<"$DUMP" | head -1)
PRO=$(jq -r --arg m "$DEVICE_MATCH" '
	.[] | select(.type=="PipeWire:Interface:Device")
	| select(.info.props["device.name"] // "" | contains($m))
	| .info.params.EnumProfile[]? | select(.name=="pro-audio") | .index' <<<"$DUMP" | head -1)
if [ -z "$DEV" ] || [ -z "$PRO" ]; then
	echo "Error: PipeWire device/profile not found (PipeWire running?)."
	exit 1
fi
echo "PipeWire device $DEV, pro-audio profile index $PRO"

# --- toggle profile to force node re-creation ----------------------------------
echo "Toggling profile off -> pro-audio..."
wpctl set-profile "$DEV" off
sleep 1
wpctl set-profile "$DEV" "$PRO"

# --- verify the sink node exists ------------------------------------------------
sleep 1
if pw-dump | jq -e --arg n "$CARD_NAME" '
	.[] | select(.type=="PipeWire:Interface:Node")
	| select(.info.props["media.class"]=="Audio/Sink")
	| select(.info.props["node.description"] // "" | contains($n))' >/dev/null; then
	echo "✓ Sink node created. '$CARD_NAME' should now be selectable in wiremix."
else
	echo "⚠ Sink node still missing."
	echo "  Try: systemctl --user restart wireplumber, or replug the interface."
	exit 1
fi
