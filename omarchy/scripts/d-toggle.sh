#!/bin/bash
# G6: DANK MATERIAL SHELL TOGGLE (Logic-Based)

# 1. If Dank is running, shut it down
if pgrep -x "dms" > /dev/null; then
    # Kill the processes gracefully
    pkill -x "dms|qs|quickshell"
    rm -f /tmp/dms-ipc.sock
    
    # Wait until the process is actually gone
    while pgrep -x "dms" > /dev/null; do
        sleep 0.1
    done
    
    # Optional: Clear Hyprland layers if needed
    hyprctl reload
    exit 0
fi

# 2. If Dank is NOT running, open it
# Clean up any orphaned sockets first
rm -f /tmp/dms-ipc.sock

# Launch via uwsm
uwsm app -- dms run -d &

(
    sleep 2
    dms ipc call theme set-color "#D0BCFF" 2>/dev/null
) &
