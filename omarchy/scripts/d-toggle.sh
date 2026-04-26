#!/bin/bash
# G5: DANK MATERIAL SHELL TOGGLE

LOCK="/tmp/g5_dank.lock"

if [ ! -f "$LOCK" ]; then
    # --- ACTION: OPEN DANK ---
    touch "$LOCK"

    # 1. Kill the 'Ghost' Noctalia and any old Dank processes
    pkill -9 -x qs 2>/dev/null
    pkill -9 -x quickshell 2>/dev/null
    killall -9 dms 2>/dev/null
    rm -f /tmp/dms-ipc.sock

    # 2. Launch using your tested terminal command
    uwsm app -- dms run -d &

    # 3. The Healer (Lavender Theme)
    (
        sleep 2
        dms ipc call theme set-color "#D0BCFF"
    ) &
else
    # --- ACTION: RETURN TO BLANK SLATE ---
    rm "$LOCK"

    # Kill everything to ensure an empty btop
    pkill -9 -x qs 2>/dev/null
    pkill -9 -x quickshell 2>/dev/null
    killall -9 dms 2>/dev/null
    rm -f /tmp/dms-ipc.sock
    
    # Reset Hyprland layers to clear the screen space
    hyprctl reload
fi
