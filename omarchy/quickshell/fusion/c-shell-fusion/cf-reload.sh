#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# 1. Kill strictly by process name
pkill quickshell

# 2. Give it a moment
sleep 0.2

# Performance & Memory Optimizations
# 3. RUNTIME ENVIRONMENT
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# 4. Fresh Launch
uwsm app -- $LAUNCH_CMD &>/dev/null &
disown
