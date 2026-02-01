#!/usr/bin/env bash
# Script to change PipeWire sample rate dynamically for audio production
# Usage: set-audio-rate.sh [rate]
# Example: set-audio-rate.sh 96000
#
# Note: This changes the rate without restarting PipeWire.
# Applications like Ardour will detect the rate change automatically.

set -euo pipefail

RATE="${1:-96000}"

# Validate rate
case "$RATE" in
44100 | 48000 | 88200 | 96000 | 176400 | 192000) ;;
*)
	echo "Error: Invalid sample rate. Must be one of: 44100, 48000, 88200, 96000, 176400, 192000"
	exit 1
	;;
esac

echo "Setting PipeWire sample rate to $RATE Hz..."

# First, ensure allowed-rates includes all rates
pw-metadata -n settings 0 clock.allowed-rates "[ 44100 48000 88200 96000 176400 192000 ]"

# Set the forced rate
pw-metadata -n settings 0 clock.force-rate "$RATE"

# Give it a moment to apply
sleep 1

# Verify
CURRENT_RATE=$(pw-cli info 0 | grep "default.clock.rate" | grep -oP '\d+' | head -1)
echo ""
echo "Current PipeWire rate: $CURRENT_RATE Hz"

if [ "$CURRENT_RATE" = "$RATE" ]; then
	echo "✓ Sample rate successfully changed to $RATE Hz"
	echo ""
	echo "Applications like Ardour will detect this change automatically."
else
	echo "⚠ Current rate is $CURRENT_RATE Hz (requested $RATE Hz)"
	echo ""
	echo "This is normal if audio is currently playing."
	echo "The rate will change when you start/restart your DAW."
	echo ""
	echo "Tip: Stop all audio playback and try again for immediate effect."
fi
