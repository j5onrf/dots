#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
# The exact command string used to launch (for precise pgrep matching)
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# Check if it's already running
if pgrep -f "$LAUNCH_CMD" > /dev/null; then
    # If running, kill it
    pkill -f "$LAUNCH_CMD"
else
    # Environment variables for consistent UI scaling
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96

    # Launch using uwsm app for session management
    # we use 'disown' to ensure the script doesn't hang onto the process
    uwsm app -- $LAUNCH_CMD &>/dev/null &
    disown
fi
