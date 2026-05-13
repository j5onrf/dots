#!/bin/bash
# --- SHELL-FUSION TOGGLE (Optimized & Portable) ---

# Dynamic path for sharing
TARGET_FILE="$HOME/.config/quickshell/shell-fusion/shell.qml"
BINARY="/usr/bin/quickshell"

# --- SHUTDOWN LOGIC ---
if pgrep -f "$BINARY -p $TARGET_FILE" > /dev/null; then
    pkill -f "$BINARY -p $TARGET_FILE"
    
    # Cleanup Quickshell state
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    exit 0
fi

# --- STARTUP LOGIC ---

# Rendering & Platform Optimizations
export QT_QPA_PLATFORM="wayland;xcb"
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export QT_QML_SINGLETON_REUSE=1

# Scaling & HiDPI Fixes
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1

# Memory Management
export MALLOC_ARENA_MAX=1

# The Launch
uwsm app -- "$BINARY" -p "$TARGET_FILE" &>/dev/null &

disown
exit 0
