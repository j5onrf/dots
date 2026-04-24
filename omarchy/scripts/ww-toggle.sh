#!/bin/bash

CONFIG="$HOME/.config/waybar/veo/config.jsonc"
STYLE="$HOME/.config/waybar/veo/style.css"

# Check if Veo specifically is running by looking for the config path
if pgrep -f "veo/config.jsonc" > /dev/null; then
    # --- SHUTDOWN VEO ---
    # Only kills the waybar instance using the veo config
    pkill -f "veo/config.jsonc"
else
    # --- STARTUP VEO ---
    # Launch only Veo via uwsm
    uwsm app -- waybar -c "$CONFIG" -s "$STYLE" &
fi
