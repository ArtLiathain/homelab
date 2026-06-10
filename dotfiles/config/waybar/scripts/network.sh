#!/usr/bin/env bash
#
# Scan, select, and connect to Wi-Fi networks using iWd (iwctl)
#
# Requirements:
# 	iwd
# 	fzf
# 	notify-send (libnotify)

# shellcheck disable=SC1090
colors=()
source ~/.config/waybar/scripts/fzf-colorizer.sh &> /dev/null || true

RED="\e[31m"
RESET="\e[39m"

TIMEOUT=5
# Most systems use wlan0; change this if yours is different (check 'iwctl device list')
DEVICE="wlan0"

ensure-enabled() {
    # Check if device is powered on
    local state
    state=$(iwctl device "$DEVICE" show | grep "Powered" | awk '{print $2}')

    if [[ $state == "on" ]]; then
        return 0
    fi

    iwctl device "$DEVICE" set-property Powered on
    sleep 1
    
    notify-send "Wi-Fi Enabled" -i "network-wireless-on" \
        -h string:x-canonical-private-synchronous:network
}

get-network-list() {
    # Trigger a scan
    iwctl station "$DEVICE" scan

    local i
    for ((i = 1; i <= TIMEOUT; i++)); do
        printf "\rScanning for networks... (%d/%d)" $i $TIMEOUT
        
        # Get list and filter out empty lines or header decorations
        networks=$(iwctl station "$DEVICE" get-networks | sed '1,4d' | grep -v '^\s*$')

        if [[ -n $networks ]]; then
            break
        fi
        sleep 1
    done

    printf "\n%bScanning stopped.%b\n\n" "$RED" "$RESET"

    if [[ -z $networks ]]; then
        notify-send "Wi-Fi" "No networks found" -i "package-broken"
        return 1
    fi
}

select-network() {
    # iwctl output formatting is different; we'll treat the SSID as the key
    local header="  Name                Type       Signal"
    
    local options=(
        "--border=sharp"
        "--border-label= Wi-Fi Networks (iWd) "
        "--header=$header"
        "--height=~100%"
        "--highlight-line"
        "--info=inline-right"
        "--reverse"
        "${colors[@]}"
    )

    # Pick the line, then extract the SSID (Name). 
    # We strip ANSI codes and leading/trailing asterisks (connected indicator)
    selected_line=$(fzf "${options[@]}" <<< "$networks")
    
    # Extract SSID: remove leading symbols and grab the first column
    ssid=$(echo "$selected_line" | sed 's/^[* ]//' | awk '{print $1}')

    if [[ -z $ssid ]]; then
        return 1
    fi

    # Check if already connected (indicated by an asterisk in iwctl)
    if [[ $selected_line == \** ]]; then
        notify-send "Wi-Fi" "Already connected to $ssid" -i "package-install"
        return 1
    fi
}

connect() {
    printf "Connecting to %s...\n" "$ssid"

    # iwctl will prompt for a password in the terminal if the network is encrypted
    # and hasn't been saved before.
    if ! iwctl station "$DEVICE" connect "$ssid"; then
        notify-send "Wi-Fi" "Failed to connect to $ssid" -i "package-purge"
        return 1
    fi

    notify-send "Wi-Fi" "Successfully connected to $ssid" -i "package-install"
}

main() {
    printf "\e[?25l"
    ensure-enabled || exit 1
    get-network-list || exit 1
    printf "\e[?25h"
    select-network || exit 1
    connect || exit 1
}

main
