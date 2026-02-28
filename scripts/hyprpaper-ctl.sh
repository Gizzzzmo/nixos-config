#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/hypr/wallpaper-groups"
STATE_FILE="$HOME/.config/hypr/wallpaper-state"
CYCLE_INTERVAL_FILE="$HOME/.config/hypr/wallpaper-cycle-interval"
CYCLE_ENABLED_FILE="$HOME/.config/hypr/wallpaper-cycle-enabled"

usage() {
    echo "Usage: $0 <command> [args]"
    echo "Commands:"
    echo "  next              Switch to next image in current group"
    echo "  prev              Switch to previous image in current group"
    echo "  group <name>      Switch to specified group"
    echo "  list-groups       List available groups"
    echo "  list-images       List images in current group"
    echo "  current           Show current group and image"
    echo "  interval <sec>    Set cycle interval (0 to disable)"
    echo "  cycle <on|off>    Enable or disable cycling"
    echo "  daemon            Start the cycling daemon"
    exit 1
}

get_groups() {
    find "$WALLPAPER_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
}

get_images() {
    local group="$1"
    find "$WALLPAPER_DIR/$group" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort
}

get_current_group() {
    if [[ -f "$STATE_FILE" ]]; then
        head -n1 "$STATE_FILE"
    else
        get_groups | head -n1
    fi
}

get_current_image() {
    local group="$1"
    if [[ -f "$STATE_FILE" ]] && [[ $(wc -l < "$STATE_FILE") -ge 2 ]]; then
        tail -n1 "$STATE_FILE"
    else
        get_images "$group" | head -n1
    fi
}

set_current() {
    local group="$1"
    local image="$2"
    echo "$group" > "$STATE_FILE"
    echo "$image" >> "$STATE_FILE"
}

switch_wallpaper() {
    local image="$1"
    hyprctl hyprpaper wallpaper ",$(realpath "$image")" >/dev/null 2>&1 || true
}

get_cycle_interval() {
    if [[ -f "$CYCLE_INTERVAL_FILE" ]]; then
        cat "$CYCLE_INTERVAL_FILE"
    else
        echo "300"
    fi
}

set_cycle_interval() {
    local interval="$1"
    echo "$interval" > "$CYCLE_INTERVAL_FILE"
}

is_cycle_enabled() {
    if [[ -f "$CYCLE_ENABLED_FILE" ]]; then
        [[ "$(cat "$CYCLE_ENABLED_FILE")" == "1" ]]
    else
        false
    fi
}

set_cycle_enabled() {
    local enabled="$1"
    if [[ "$enabled" == "1" ]]; then
        echo "1" > "$CYCLE_ENABLED_FILE"
    else
        rm -f "$CYCLE_ENABLED_FILE"
    fi
}

daemon() {
    local interval
    interval=$(get_cycle_interval)
    
    if [[ "$interval" -eq 0 ]]; then
        return 0
    fi
    counter=0
    
    while true; do
        interval=$(get_cycle_interval)
        if is_cycle_enabled && [[ "$interval" -gt 0 ]] && [[ $counter -ge $interval ]]; then
            counter=0
            if [[ -f "$STATE_FILE" ]]; then
                group=$(get_current_group)
                if [[ -n "$group" ]] && [[ -d "$WALLPAPER_DIR/$group" ]]; then
                    images=($(get_images "$group"))
                    if [[ ${#images[@]} -gt 0 ]]; then
                        current=$(get_current_image "$group")
                        current_idx=-1
                        for i in "${!images[@]}"; do
                            if [[ "${images[$i]}" == "$current" ]]; then
                                current_idx=$i
                                break
                            fi
                        done
                        next_idx=$(( (current_idx + 1) % ${#images[@]} ))
                        new_image="${images[$next_idx]}"
                        set_current "$group" "$new_image"
                        switch_wallpaper "$new_image"
                    fi
                fi
            fi
        fi
        sleep 1
        counter=$((counter + 1))
    done
}

command="$1"
shift || true

case "$command" in
    next|prev)
        group=$(get_current_group)
        images=($(get_images "$group"))
        [[ ${#images[@]} -eq 0 ]] && { echo "No images found in group '$group'"; exit 1; }
        
        current=$(get_current_image "$group")
        current_idx=-1
        for i in "${!images[@]}"; do
            if [[ "${images[$i]}" == "$current" ]]; then
                current_idx=$i
                break
            fi
        done
        
        if [[ "$command" == "next" ]]; then
            next_idx=$(( (current_idx + 1) % ${#images[@]} ))
        else
            next_idx=$(( (current_idx - 1 + ${#images[@]}) % ${#images[@]} ))
        fi
        
        new_image="${images[$next_idx]}"
        set_current "$group" "$new_image"
        switch_wallpaper "$new_image"
        ;;
    group)
        [[ -z "$1" ]] && { echo "Error: group name required"; exit 1; }
        group="$1"
        if [[ ! -d "$WALLPAPER_DIR/$group" ]]; then
            echo "Error: group '$group' not found"
            exit 1
        fi
        images=($(get_images "$group"))
        [[ ${#images[@]} -eq 0 ]] && { echo "Error: no images in group '$group'"; exit 1; }
        new_image="${images[0]}"
        set_current "$group" "$new_image"
        switch_wallpaper "$new_image"
        ;;
    list-groups)
        get_groups
        ;;
    list-images)
        group=$(get_current_group)
        get_images "$group"
        ;;
    current)
        group=$(get_current_group)
        image=$(get_current_image "$group")
        echo "Group: $group"
        echo "Image: $image"
        ;;
    interval)
        [[ -z "$1" ]] && { echo "Error: interval in seconds required"; exit 1; }
        set_cycle_interval "$1"
        ;;
    cycle)
        [[ -z "$1" ]] && { echo "Error: 'on' or 'off' required"; exit 1; }
        if [[ "$1" == "on" ]]; then
            set_cycle_enabled 1
        elif [[ "$1" == "off" ]]; then
            set_cycle_enabled 0
        else
            echo "Error: use 'on' or 'off'"
            exit 1
        fi
        ;;
    daemon)
        daemon
        ;;
    randomize)
        groups=($(get_groups))
        [[ ${#groups[@]} -eq 0 ]] && { echo "No groups found"; exit 1; }
        random_idx=$((RANDOM % ${#groups[@]}))
        random_group="${groups[$random_idx]}"
        images=($(get_images "$random_group"))
        [[ ${#images[@]} -eq 0 ]] && { echo "No images in group '$random_group'"; exit 1; }
        new_image="${images[0]}"
        set_current "$random_group" "$new_image"
        switch_wallpaper "$new_image"
        ;;
    *)
        usage
        ;;
esac
