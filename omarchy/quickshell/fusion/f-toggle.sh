#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# Check if it's already running
if pgrep -f "$LAUNCH_CMD" > /dev/null; then
    pkill -f "$LAUNCH_CMD"
else
    # --- Wallpaper Logic ---
    # Omarchy stores the current theme name in this file
    if [ -f "$HOME/.config/omarchy/theme" ]; then
        CURRENT_THEME=$(cat "$HOME/.config/omarchy/theme")
        # Find the first image in the theme's background folder
        WALLPAPER=$(find "$HOME/.config/omarchy/backgrounds/$CURRENT_THEME" -type f | head -n 1)
        
        if [ -n "$WALLPAPER" ]; then
            # Using swww (Omarchy's default) to set the wall
            swww img "$WALLPAPER" --transition-type grow --transition-pos top-right --transition-duration 1 &
        fi
    fi

    # Performance & Memory Optimizations
    export QSG_RENDER_LOOP=basic
    export QML_DISABLE_DISK_CACHE=1
    export MALLOC_ARENA_MAX=1
    export QT_QML_SINGLETON_REUSE=1
    export MALLOC_TRIM_THRESHOLD_=131072

    # Scaling Fixes
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96

    uwsm app -- $LAUNCH_CMD &>/dev/null &
    disown
fi
