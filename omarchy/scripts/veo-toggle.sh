#!/bin/bash

CONFIG="$HOME/.config/waybar/veo/config.jsonc"
STYLE="$HOME/.config/waybar/veo/style.css"

# Check if Veo specifically is running
if pgrep -f "veo/config.jsonc" > /dev/null; then
    # --- TURN OFF VEO ---
    pkill -f "veo/config.jsonc"
    
    # Clean up the daemons Omarchy uses
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
else
    # --- TURN ON VEO ---
    # Clear the D-Bus seats just in case a shell left them hanging
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
    sleep 0.1 

    # Launch Veo
    uwsm app -- waybar -c "$CONFIG" -s "$STYLE" &

    # Restart the supporting Omarchy daemons
    uwsm app -- mako &
    uwsm app -- swayosd-server &
    uwsm app -- walker --gapplication-service &
fi
