#!/bin/bash
# --- SHELL-FUSION TOGGLE ---

TARGET_FILE="$HOME/.config/quickshell/shell-fusion/shell.qml"
BINARY="/usr/bin/quickshell"

if pgrep -f "$BINARY -p $TARGET_FILE" > /dev/null; then
    pkill -f "$BINARY -p $TARGET_FILE"
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    exit 0
fi

# Performance
export QT_QPA_PLATFORM="wayland;xcb"
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export QT_QML_SINGLETON_REUSE=1
export MALLOC_ARENA_MAX=1

uwsm app -- "$BINARY" -p "$TARGET_FILE" &>/dev/null &

disown
exit 0
