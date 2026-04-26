#!/bin/bash

# Absolute path to your local config
CAELESTIA_DIR="/home/j5/.config/quickshell/caelestia"

if pgrep -x "quickshell" > /dev/null; then
    # --- TOGGLE OFF ---
    pkill -x "quickshell"
else
    # --- TOGGLE ON ---
    # Using your specific scale overrides for the ultrawide
    uwsm app -- env QT_AUTO_SCREEN_SCALE_FACTOR=0 \
               QT_SCALE_FACTOR=1 \
               QT_FONT_DPI=96 \
               quickshell -c "$CAELESTIA_DIR" > /dev/null 2>&1 &
fi
