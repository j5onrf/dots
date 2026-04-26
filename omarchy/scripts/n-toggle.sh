#!/bin/bash

# Define the binary we built
NOCTALIA_BIN="/usr/local/bin/qs"

# 1. If Noctalia is running, shut it down completely
if pgrep -x "qs" > /dev/null; then
    # Kill the process
    pkill -x "qs"
    
    # Wait until the process is actually gone before finishing
    # This ensures the Wayland surface is released totally
    while pgrep -x "qs" > /dev/null; do
        sleep 0.1
    done
    exit 0
fi

# 2. If Noctalia is NOT running, open it
# Using your specific scaling and env vars
uwsm app -- env QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 QT_FONT_DPI=96 \
$NOCTALIA_BIN -c noctalia &
