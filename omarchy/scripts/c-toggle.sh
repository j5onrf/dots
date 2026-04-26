#!/bin/bash
# Caelestia Shell Toggle

CAELESTIA_DIR="/home/j5/.config/quickshell/caelestia"

if pgrep -x "quickshell" > /dev/null; then
    # --- TOGGLE OFF ---
    pkill -x "quickshell"
    
    # Wait until it's actually gone to free up the Wayland surface
    while pgrep -x "quickshell" > /dev/null; do
        sleep 0.1
    done
else
    # --- TOGGLE ON ---
    # Optional: Clean up potential ghost sockets if Caelestia uses them
    # rm -f /tmp/quickshell.sock 2>/dev/null

    uwsm app -- env QT_AUTO_SCREEN_SCALE_FACTOR=0 \
               QT_SCALE_FACTOR=1 \
               QT_FONT_DPI=96 \
               quickshell -c "$CAELESTIA_DIR" > /dev/null 2>&1 &
fi
