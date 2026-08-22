#!/bin/bash

# ==============================================================================
# C-Shell Reload Hook — Universal Theme-Set Dispatcher
# ==============================================================================

# 1. Resolve Target QML Path (Environment variable -> Common paths)
if [ -n "$C_SHELL_PATH" ] && [ -f "$C_SHELL_PATH" ]; then
    TARGET="$C_SHELL_PATH"
elif [ -f "$HOME/.config/quickshell/shell-fusion/c-shell.qml" ]; then
    TARGET="$HOME/.config/quickshell/shell-fusion/c-shell.qml"
elif [ -f "$HOME/.config/quickshell/c-shell.qml" ]; then
    TARGET="$HOME/.config/quickshell/c-shell.qml"
else
    TARGET="$HOME/.config/quickshell/c-shell.qml"
fi

# 2. Performance & Low-Memory Environment
export MALLOC_ARENA_MAX=1
export MALLOC_TRIM_THRESHOLD_=65536
export MALLOC_MMAP_THRESHOLD_=65536
export QSG_RENDER_LOOP=basic
export QT_QUICK_CONTROLS_STYLE=Basic
export QT_QML_SINGLETON_REUSE=1
export QML_DISABLE_DISK_CACHE=0

# 3. Asynchronously restart the dock (Prevents blocking other theme-set hooks)
(
    # Brief pause for the theme engine to write colors to disk
    sleep 0.2
    
    # Kill ONLY this specific dock (Preserves Omarchy's background/shell instance)
    pkill -f "c-shell.qml" 2>/dev/null || true
    sleep 0.1
    
    # Launch new instance
    quickshell -p "$TARGET" &>/dev/null &
    disown
    
    # Trigger Omarchy shell refresh if running
    command -v omarchy-shell >/dev/null 2>&1 && omarchy-shell -q omarchy.indicators refresh 2>/dev/null || true
) &

disown
exit 0
