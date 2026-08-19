#!/bin/bash

# Target QML file
TARGET="$HOME/.config/quickshell/shell-fusion/c-shell.qml"

# 1. Toggle OFF if already running
if pgrep -f "c-shell.qml" >/dev/null 2>&1; then
    pkill -f "c-shell.qml"
    exit 0
fi

# 2. Low-Memory Environment Flags (Drops RAM from ~250MB to ~50MB)
export MALLOC_ARENA_MAX=1
export MALLOC_TRIM_THRESHOLD_=65536
export MALLOC_MMAP_THRESHOLD_=65536
export QSG_RENDER_LOOP=basic
export QT_QUICK_CONTROLS_STYLE=Basic
export QT_QML_SINGLETON_REUSE=1

# 3. Launch bar
quickshell -p "$TARGET" &>/dev/null &

disown
exit 0
