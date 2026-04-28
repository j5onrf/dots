#!/bin/bash

# Configuration
TARGET_DIR="$HOME/.config/quickshell/shell-fusion"
LAUNCH_CMD="quickshell -c $TARGET_DIR"

# 1. Kill any existing instances first
pkill -f "$LAUNCH_CMD"

# 2. Small sleep to ensure the process has actually exited
sleep 0.2

# 3. Environment variables
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1
export QT_FONT_DPI=96

# 4. Fresh Launch
uwsm app -- $LAUNCH_CMD &>/dev/null &
disown
