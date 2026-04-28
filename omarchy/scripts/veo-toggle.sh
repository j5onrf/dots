#!/bin/bash

CONFIG="$HOME/.config/waybar/veo/config.jsonc"
STYLE="$HOME/.config/waybar/veo/style.css"
WALLPAPER="$HOME/.config/omarchy/current/background"

if pgrep -f "veo/config.jsonc" > /dev/null; then
    # --- TURN OFF VEO ---
    pkill -f "veo/config.jsonc"
    pkill -9 mako 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
else
    # --- TURN ON VEO ---
    pkill -9 mako 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
    pkill swaybg 2>/dev/null
    sleep 0.1 

    uwsm-app -- swaybg -i "$WALLPAPER" -m fill &

    # Launch UI Tools (Notice Walker is gone from here)
    uwsm-app -- waybar -c "$CONFIG" -s "$STYLE" &
    uwsm-app -- mako &
    # Add swayosd or other tools here if needed, but NOT walker
fi
