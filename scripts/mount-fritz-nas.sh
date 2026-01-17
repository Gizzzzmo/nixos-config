#!/bin/sh
# Expects MOUNT_CIFS, MOUNTPOINT_BIN, and UMOUNT to be set via environment
ACTION=$2

MOUNT_POINT="/home/jonas/mnt/fritz-nas"
CREDS_FILE="/home/jonas/shared/.smbcredentials"

# Send notification to user's Hyprland session
notify_user() {
	# Get HYPRLAND_INSTANCE_SIGNATURE from runtime directory
	HYPR_SIGNATURE=$(ls /run/user/1000/hypr/ 2>/dev/null | head -1)

	# Send notification if signature was found (Hyprland is running)
	if [ -n "$HYPR_SIGNATURE" ]; then
		su -s /bin/sh jonas -c \
			"HYPRLAND_INSTANCE_SIGNATURE='$HYPR_SIGNATURE' hyprctl notify 2 5000 'rgb(ff0000)' '$1'" \
			2>/dev/null || true
	fi
}

if [ "$ACTION" = "up" ] && { [ "$CONNECTION_ID" = "devolo-ae3" ] || [ "$CONNECTION_ID" = "FRITZ!Box 7530 EL" ]; }; then
	# Wait for network to stabilize
	sleep 2

	# Create mount point if it doesn't exist
	mkdir -p "$MOUNT_POINT"

	# Check if mount point is already occupied
	if "$MOUNTPOINT_BIN" -q "$MOUNT_POINT"; then
		# Try to clean up stale mount
		if ! "$UMOUNT" -fl "$MOUNT_POINT" 2>/dev/null; then
			# Mount point is busy - notify user
			notify_user "Fritz NAS: Mount point is busy, cannot remount"
			exit 0
		fi
	fi

	# Mount the FRITZ!Box NAS
	if [ -f "$CREDS_FILE" ]; then
		"$MOUNT_CIFS" //192.168.178.1/FRITZ.NAS "$MOUNT_POINT" \
			-o credentials="$CREDS_FILE",uid=1000,noserverino
	fi
fi

if [ "$ACTION" = "down" ] && { [ "$CONNECTION_ID" = "devolo-ae3" ] || [ "$CONNECTION_ID" = "FRITZ!Box 7530 EL" ]; }; then
	# Force unmount to ensure cleanup even if filesystem is busy
	# Programs will fail anyway once network is down
	if "$MOUNTPOINT_BIN" -q "$MOUNT_POINT"; then
		if ! "$UMOUNT" -fl "$MOUNT_POINT" 2>/dev/null; then
			notify_user "Fritz NAS: Failed to unmount"
		fi
	fi
fi
