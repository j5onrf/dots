#!/bin/bash
#
# Attention! Script has exec call every second. I will not be using it. This was just a test. It works and is cool.
#
# Name: icon-switch-hyprshade.sh
# Desc: Manages Hyprshade state for Waybar using a reliable state file.
#       It can both TOGGLE the state and REPORT the current icon.
#

# --- CONFIGURATION ---
STATE_FILE="/tmp/hyprshade.state"
DEFAULT_SHADER="blue-light-filter-50" # Change to your preferred shader

# --- ACTION HANDLER ---
# This block only runs if the script is called with an argument (e.g., "toggle").
# This is what happens when you LEFT-CLICK the Waybar module.
if [ "$1" == "toggle" ]; then
    # Check if the state file exists to determine the current state.
    if [ -f "$STATE_FILE" ]; then
        # It's ON, so turn it OFF.
        hyprshade off
        rm "$STATE_FILE"
    else
        # It's OFF, so turn it ON.
        hyprshade on "$DEFAULT_SHADER"
        touch "$STATE_FILE"
    fi
fi

# --- DISPLAY REPORTER ---
# This block ALWAYS runs, whether you clicked or not.
# Its only job is to tell Waybar what to display right now.
if [ -f "$STATE_FILE" ]; then
    # If the state file exists, output the JSON for the "ON" icon.
    echo '{"text": "\ue019"}'
else
    # If the state file does not exist, output the JSON for the "OFF" icon.
    echo '{"text": "\ue018"}'
fi
