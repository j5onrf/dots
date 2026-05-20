#!/bin/bash
# --- NOCTALIA TOGGLE (Robust v5) 5-20-26 ---

NOCTALIA_BIN_PATH="/home/j5/.config/quickshell/noctalia/noctalia-bin"
# Identify the process name (usually the filename of the binary)
PROC_NAME="noctalia-bin"

# --- SHUTDOWN LOGIC ---
# We check for the specific binary name instead of 'qs'
if pgrep -x "$PROC_NAME" > /dev/null; then
    # Kill the specific process
    pkill -x "$PROC_NAME"
    
    # Optional: Clear the socket so the next launch is clean
    rm -rf /run/user/1000/quickshell/* 2>/dev/null
    
    # Restart mako (standard notification daemon)
    uwsm app -- mako & 
    makoctl dismiss -a 2>/dev/null
    
    # Force kill if it's being stubborn
    timeout 2s bash -c "while pgrep -x '$PROC_NAME' > /dev/null; do sleep 0.1; done"
    pgrep -x "$PROC_NAME" >/dev/null && pkill -9 -x "$PROC_NAME"
    exit 0
fi

# --- STARTUP LOGIC ---

export QT_QPA_PLATFORM="wayland;xcb"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export QT_QML_SINGLETON_REUSE=1

# Kill mako to let Noctalia handle notifications
pkill -9 mako 2>/dev/null
systemctl --user stop mako.service 2>/dev/null

# Launch using the absolute path to the binary
uwsm app -- "$NOCTALIA_BIN_PATH" -c "$HOME/.config/quickshell/noctalia" &>/dev/null &

disown
exit 0
