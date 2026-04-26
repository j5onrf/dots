#!/bin/bash

# Define the wallpaper path from your autostart for consistency
WALLPAPER="$HOME/.config/omarchy/current/background"

if pgrep -x "waybar" > /dev/null; then
    # --- SHUTDOWN (Return to Blank Slate) ---
    omarchy-toggle-waybar
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null 
else
    # --- STARTUP (Bring back the UI) ---
    # Ensure a clean slate before bringing the bar back
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
    pkill swaybg 2>/dev/null # Prevent duplicate wallpaper processes
    sleep 0.1 

    # 1. Reload the Wallpaper (Omarchy style)
    if [ -f "$WALLPAPER" ]; then
        uwsm-app -- swaybg -i "$WALLPAPER" -m fill &
    fi

    # 2. Launch UI Tools
    omarchy-toggle-waybar
    uwsm-app -- mako &
    uwsm-app -- walker --gapplication-service &
fi
