#!/bin/bash
# --- SHELL-FUSION TOGGLE V6.0 (Unified) ---

TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
# We target the specific entry file for more reliable pgrep matching
TARGET_FILE="$TARGET_DIR/shell.qml"
LAUNCH_CMD="quickshell -p $TARGET_DIR"

# 1. SHUTDOWN LOGIC
# We check for the binary and the specific config path in the process args
if pgrep -f "quickshell.*$TARGET_DIR" > /dev/null; then
    echo "Shell-Fusion detected. Shutting down..."
    
    # Use -9 (SIGKILL) only if necessary, but -f is crucial here
    pkill -f "quickshell.*$TARGET_DIR"
    
    # Optional: cleanup specific to quickshell's runtime sockets/cache
    rm -rf /run/user/$(id -u)/quickshell/* 2>/dev/null
    
    # Dismiss notifications if mako is used
    makoctl dismiss -a 2>/dev/null
    exit 0
fi

# 2. STARTUP LOGIC
echo "Shell-Fusion not found. Starting..."

# Performance & Environment Exports
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1
export QT_QPA_PLATFORM="wayland;xcb"

# Wallpaper Management (Swaybg)
WALLPAPER="$HOME/.config/omarchy/current/background"
if [ -e "$WALLPAPER" ]; then
    pgrep swaybg > /dev/null || swaybg -i "$WALLPAPER" -m fill &
fi

# Launch using uwsm for session tracking
# We use the full path to the binary to ensure uwsm handles it correctly
uwsm app -- /usr/bin/quickshell -p "$TARGET_DIR" &>/dev/null &

disown
exit 0
