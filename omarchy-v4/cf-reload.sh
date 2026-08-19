#!/bin/bash

# 1. Give Omarchy a brief moment to finish writing the theme state
sleep 0.3

# 2. Kill strictly YOUR custom bar process (DO NOT use 'pkill quickshell')
pkill -f "c-shell.qml"
sleep 0.2

# 3. Performance & Runtime Environment
export QSG_RENDER_LOOP=threaded 
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# 4. Fresh launch of your custom bar
/usr/local/bin/quickshell -p "$HOME/.config/quickshell/shell-fusion/c-shell.qml" &>/dev/null &

disown
exit 0
