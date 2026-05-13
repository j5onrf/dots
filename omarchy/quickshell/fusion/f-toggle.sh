#!/bin/bash
# --- SHELL-FUSION TOGGLE V6.3 (Clean & Focused) ---

TARGET_DIR="$HOME/.config/quickshell/shell-fusion"

# 1. SHUTDOWN LOGIC
if pgrep -f "quickshell.*$TARGET_DIR" > /dev/null; then
    pkill -f "quickshell.*$TARGET_DIR"
    
    # Essential cleanup for Quickshell sockets
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    exit 0
fi

# 2. STARTUP LOGIC

# Wallpaper management
WALLPAPER="$HOME/.config/omarchy/current/background"
if [ -e "$WALLPAPER" ]; then
    pgrep swaybg > /dev/null || swaybg -i "$WALLPAPER" -m fill &
fi

# Performance tweaks
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# Launch via uwsm
uwsm app -- /usr/bin/quickshell -p "$TARGET_DIR" &>/dev/null &

disown
exit 0
