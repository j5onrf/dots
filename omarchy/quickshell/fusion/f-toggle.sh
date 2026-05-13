#!/bin/bash
# --- SHELL-FUSION TOGGLE ---

TARGET_FILE="$HOME/.config/quickshell/shell-fusion/shell.qml"
BINARY="/usr/bin/quickshell"

# --- SHUTDOWN LOGIC ---
# Find the specific quickshell process running this QML file
if pgrep -f "$BINARY -p $TARGET_FILE" > /dev/null; then
    pkill -f "$BINARY -p $TARGET_FILE"
    
    # Clean up quickshell's internal socket/cache
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    exit 0
fi

# --- STARTUP LOGIC ---
# Standard Wayland/Qt environment
export QT_QPA_PLATFORM="wayland"
export QSG_RENDER_LOOP=threaded

# Launch using uwsm for performance, but only the bar itself
uwsm app -- "$BINARY" -p "$TARGET_FILE" &>/dev/null &

disown
exit 0
