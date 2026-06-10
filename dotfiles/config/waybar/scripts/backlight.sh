#!/usr/bin/env bash

VALUE=${2:-5}
ACTION=$1

# 1. Detection
if [ -d "/sys/class/backlight" ] && [ "$(ls -A /sys/class/backlight)" ]; then
    MODE="laptop"
else
    MODE="desktop"
fi

get_level() {
    if [[ "$MODE" == "laptop" ]]; then
        brightnessctl -m | awk -F "," '{print $4}' | tr -d '%'
    else
        # FIXED: Changed rs.wl-gammarelay to rs.wl.gammarelay
        local raw=$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Brightness | awk '{print $2}')
        
        if [[ -z "$raw" ]]; then
            echo "100"
        else
            awk "BEGIN {print int($raw * 100)}"
        fi
    fi
}

adjust() {
    if [[ "$MODE" == "laptop" ]]; then
        [[ "$ACTION" == "up" ]] && brightnessctl set "${VALUE}%+" > /dev/null 2>&1
        [[ "$ACTION" == "down" ]] && brightnessctl set "${VALUE}%-" > /dev/null 2>&1
    else
        local step=$(awk "BEGIN {print $VALUE / 100}")
        [[ "$ACTION" == "down" ]] && step="-$step"
        
        # Use '--' to tell busctl that 'step' isn't a flag
        busctl --user call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -- "$step"
    fi
}

case $ACTION in
    "get")
        level=$(get_level)
        echo "{\"percentage\": $level}"
        ;;
    "up"|"down")
        adjust
        level=$(get_level)
        notify-send "Brightness" "${level}%" -h int:value:"$level" -h string:x-canonical-private-synchronous:brightness -i contrast
        pkill -RTMIN+10 waybar
        ;;
esac
