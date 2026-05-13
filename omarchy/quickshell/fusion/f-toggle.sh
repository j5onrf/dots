#!/bin/bash
# --- SHELL-FUSION TOGGLE ---

TARGET_FILE="$HOME/.config/quickshell/shell-fusion/shell.qml"
BINARY="/usr/bin/quickshell"

if pgrep -x "quickshell" > /dev/null && pgrep -f "$TARGET_FILE" > /dev/null; then
    echo "Bar detected. Terminating..."
    
    # Kill every instance of quickshell running this specific file
    pkill -9 -f "$TARGET_FILE"
    
    # Essential: Clear the Wayland/Quickshell sockets
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    
    # Exit here so we don't start a new one
    exit 0
fi

# 2. THE STARTUP: (If we reached here, no bar was found)

# Performance Exports
export QT_QPA_PLATFORM="wayland;xcb"
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export QT_QML_SINGLETON_REUSE=1
export MALLOC_ARENA_MAX=1

# Double-check cleanup before launch just to be safe
pkill -f "$TARGET_FILE" 2>/dev/null
rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null

# Launch
uwsm app -- "$BINARY" -p "$TARGET_FILE" &>/dev/null &

disown
exit 0
