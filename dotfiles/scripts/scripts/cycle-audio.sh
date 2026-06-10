#!/bin/bash
# Get all analog sinks (ordered list)
sinks=($(pactl list short sinks | awk '{print $2}' | grep -i "analog"))

# Exit if we don't find at least one
if [[ ${#sinks[@]} -eq 0 ]]; then
    notify-send "Audio Switch" "No analog sinks found."
    exit 1
fi

# Get current default sink
current=$(pactl get-default-sink)

# Find index of current sink in our list
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current" ]]; then
        next_index=$(( (i + 1) % ${#sinks[@]} ))
        next_sink="${sinks[$next_index]}"
        # Set new default sink
        pactl set-default-sink "$next_sink"

        # Move all active streams to the new sink
        pactl list short sink-inputs | while read -r stream; do
            stream_id=$(echo "$stream" | cut -f1)
            pactl move-sink-input "$stream_id" "$next_sink"
        done
	exit 0
        notify-send "Audio Switch" "Switched to: $next_sink"
    fi
done

# If current sink not in the list, just set the first one
pactl set-default-sink "${sinks[0]}"
notify-send "Audio Switch" "Switched to: ${sinks[0]}"
