#!/bin/bash

# Define your default "Toggle" temperature
DEFAULT_TEMP="3500"

if [[ "$1" == "rofi" ]]; then
    # Open Rofi to select temperature
    options="Off\n3000K (Warm)\n3500K (Balanced)\n4000K (Soft)\n5000K (Cool)"
    choice=$(echo -e "$options" | rofi -dmenu -i -p "Hyprsunset Temp")

    if [ ! -z "$choice" ]; then
        killall hyprsunset 2>/dev/null
        if [ "$choice" != "Off" ]; then
            # Extract just the numbers (e.g., 3000 from 3000K)
            temp=$(echo "$choice" | grep -o '[0-9]\+')
            hyprsunset -t $temp &
            notify-send "Hyprsunset" "Set to ${temp}K"
        else
            notify-send "Hyprsunset" "Deactivated"
        fi
    fi

elif [[ "$1" == "toggle" ]]; then
    # Simple Toggle logic
    if pgrep -x "hyprsunset" > /dev/null; then
        killall hyprsunset
        notify-send "Hyprsunset" "Deactivated"
    else
        hyprsunset -t $DEFAULT_TEMP &
        notify-send "Hyprsunset" "Activated (${DEFAULT_TEMP}K)"
    fi
fi
