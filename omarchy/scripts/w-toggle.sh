#!/bin/bash

# Define the wallpaper path from your autostart for consistency
WALLPAPER="$HOME/.config/omarchy/current/background"

if pgrep -x "waybar" > /dev/null; then
    # --- SHUTDOWN (Return to Blank Slate) ---
    
    # 1. Kill Mako FIRST while the D-Bus connection is still "active"
    # makoctl dismiss handles any visible bubbles so they don't get stuck on screen
    makoctl dismiss -a 2>/dev/null
    pkill -x mako
    
    # 2. Toggle the bar off
    omarchy-toggle-waybar
    
    # 3. Clean up the rest of the stack
    pkill -x walker
    pkill -f swayosd-server
    
    # Wait a beat to ensure the D-Bus service is actually released
    sleep 0.2
else
    # --- STARTUP (Bring back the UI) ---
    
    # Prevent duplicate process stacking
    pkill -x mako 2>/dev/null
    pkill -x walker 2>/dev/null
    pkill -f swayosd-server 2>/dev/null
    pkill swaybg 2>/dev/null 
    
    sleep 0.1 

    # 1. Reload the Wallpaper
    if [ -f "$WALLPAPER" ]; then
        uwsm app -- swaybg -i "$WALLPAPER" -m fill &
    fi

    # 2. Launch UI Tools
    # We launch Mako before the bar so notifications are ready immediately
    uwsm app -- mako &
    uwsm app -- walker --gapplication-service &
    
    # 3. Bring in the bar
    omarchy-toggle-waybar
fi
