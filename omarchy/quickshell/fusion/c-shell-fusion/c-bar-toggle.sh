#!/bin/bash

# --- PROJECT PATHS ---
TARGET_DIR="$HOME/.config/quickshell/c-shell-fusion.qml"

# 1. TOGGLE SYSTEM (Kill if already active)
if pgrep -f "quickshell.*$TARGET_DIR" > /dev/null; then
    pkill -f "quickshell.*$TARGET_DIR"
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    exit 0
fi

# 2. RUNTIME ENVIRONMENT
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0

# Clean Execution targeting the c-bar project layout directory
/usr/local/bin/quickshell -p "$TARGET_DIR" &>/dev/null &

disown
exit 0
