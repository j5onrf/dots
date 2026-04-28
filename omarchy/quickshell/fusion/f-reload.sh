#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# 1. Kill any existing instances first
pkill -f "$LAUNCH_CMD"

# 2. Small sleep to ensure the process has actually exited
sleep 0.2

    # Performance & Memory Optimizations
    export QSG_RENDER_LOOP=basic
    export QML_DISABLE_DISK_CACHE=1
    export MALLOC_ARENA_MAX=1             # Reduced from 2 to 1 for even tighter control
    export QT_QML_SINGLETON_REUSE=1
    export MALLOC_TRIM_THRESHOLD_=131072 # Force glibc to release memory back to OS sooner
    
    # Existing Scaling Fixes
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96

# 4. Fresh Launch
uwsm app -- $LAUNCH_CMD &>/dev/null &
disown
