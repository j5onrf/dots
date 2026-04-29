#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# Check if it's already running
if pgrep -f "$LAUNCH_CMD" > /dev/null; then
    # --- SHUTDOWN LOGIC ---
    pkill -f "$LAUNCH_CMD"
    
    # NEW: Kill Mako when Fusion closes to free up the notification slot
    makoctl dismiss -a 2>/dev/null
    pkill -x mako
    
    # Optional: Wait for cleanup
    while pgrep -f "$LAUNCH_CMD" > /dev/null; do
        sleep 0.1
    done
else
    # --- STARTUP LOGIC ---
    
    # NEW: Start Mako so Shell-Fusion has its notification daemon ready
    # We use uwsm to ensure it's tracked in the session
    uwsm app -- mako &

    # --- Wallpaper Logic ---
    WALLPAPER="$HOME/.config/omarchy/current/background"
    if [ -L "$WALLPAPER" ] || [ -f "$WALLPAPER" ]; then
        pkill swaybg
        swaybg -i "$WALLPAPER" -m fill &
    fi

    # Performance & Memory Optimizations
    export QSG_RENDER_LOOP=basic
    export QML_DISABLE_DISK_CACHE=1
    export MALLOC_ARENA_MAX=1
    export QT_QML_SINGLETON_REUSE=1
    export MALLOC_TRIM_THRESHOLD_=131072

    # Existing Scaling Fixes
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96

    uwsm app -- $LAUNCH_CMD &>/dev/null &
    disown
fi
