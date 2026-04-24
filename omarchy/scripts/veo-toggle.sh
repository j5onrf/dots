#!/bin/bash

CONFIG="$HOME/.config/waybar/veo/config.jsonc"
STYLE="$HOME/.config/waybar/veo/style.css"
# This matches your autostart's logic
WALLPAPER="$HOME/.config/omarchy/current/background"

# Check if Veo specifically is running
if pgrep -f "veo/config.jsonc" > /dev/null; then
    # --- TURN OFF VEO ---
    pkill -f "veo/config.jsonc"
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
else
    # --- TURN ON VEO ---
    # 1. Clear the deck
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
    pkill swaybg 2>/dev/null
    sleep 0.1 

    # 2. Re-load the Omarchy background using swaybg
    # We use uwsm-app to keep it consistent with your autostart
    uwsm-app -- swaybg -i "$WALLPAPER" -m fill &

    # 3. Launch UI Tools
    uwsm-app -- waybar -c "$CONFIG" -s "$STYLE" &
    uwsm-app -- mako &
    uwsm-app -- walker --gapplication-service &
fi
