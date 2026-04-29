#!/bin/bash
# Caelestia Shell Toggle - Stock Version

CAELESTIA_DIR="/home/j5/.config/quickshell/caelestia"

if pgrep -f "quickshell -c $CAELESTIA_DIR" > /dev/null; then
    # --- TOGGLE OFF ---
    pkill -f "quickshell -c $CAELESTIA_DIR"
    
    while pgrep -f "quickshell -c $CAELESTIA_DIR" > /dev/null; do
        sleep 0.1
    done
else
    # --- TOGGLE ON ---
    uwsm app -- env QT_AUTO_SCREEN_SCALE_FACTOR=0 \
               QT_SCALE_FACTOR=1 \
               QT_FONT_DPI=96 \
               quickshell -c "$CAELESTIA_DIR" > /dev/null 2>&1 &
fi
