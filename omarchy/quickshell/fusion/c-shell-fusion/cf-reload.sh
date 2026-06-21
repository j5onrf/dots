#!/bin/bash

# 1. Give Omarchy a moment to finish writing theme files to disk
sleep 0.5

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="/usr/local/bin/quickshell -p $TARGET_DIR/c-shell.qml"

# 2. Kill strictly by process name
pkill quickshell
sleep 0.2

# Performance & Memory Optimizations
# 3. RUNTIME ENVIRONMENT
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# 4. Fresh Launch (Output silenced)
uwsm app -- $LAUNCH_CMD &>/dev/null &
disown
