#!/bin/bash

# Configuration: Set the path to your c-shell.qml
TARGET="${C_SHELL_PATH:-$HOME/.config/quickshell/c-shell.qml}"

# 1. Give the theme engine a brief moment to finish writing state
sleep 0.3

# 2. Kill strictly this dock process (DO NOT use generic 'pkill quickshell')
pkill -f "c-shell.qml" 2>/dev/null || true
sleep 0.2

# 3. Performance & Runtime Environment
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# 4. Launch dock
quickshell -p "$TARGET" &>/dev/null &

disown
exit 0
