#!/bin/bash
# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
# Use -p for an explicit path to avoid config-name resolution issues
LAUNCH_CMD="quickshell -p $TARGET_DIR"

if pgrep -f "quickshell -p $TARGET_DIR" > /dev/null; then
    # --- SHUTDOWN LOGIC ---
    pkill -f "quickshell -p $TARGET_DIR"
    # Don't kill mako here if the system manages it; just dismiss alerts
    makoctl dismiss -a 2>/dev/null
else
    # --- STARTUP LOGIC ---
    
    # Wallpaper (Check if swaybg is already running to avoid flickering)
    WALLPAPER="$HOME/.config/omarchy/current/background"
    if [ -e "$WALLPAPER" ]; then
        pgrep swaybg > /dev/null || swaybg -i "$WALLPAPER" -m fill &
    fi

    # Performance & Memory (Adjusted forIntel Xe)
    export QSG_RENDER_LOOP=threaded     # Threaded is better for 120Hz/Ultrawide
    export QML_DISABLE_DISK_CACHE=0     # Enable cache to prevent re-parsing crashes
    export MALLOC_ARENA_MAX=1
    export QT_QML_SINGLETON_REUSE=1
    
    # Scaling Fixes
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96

    # Launch using uwsm for session tracking
    uwsm app -- $LAUNCH_CMD &>/dev/null &
    disown
fi
