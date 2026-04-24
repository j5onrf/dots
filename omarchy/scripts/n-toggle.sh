#!/bin/bash

# If Noctalia is running (using its unique binary or config path), kill it
if pgrep -x "qs" > /dev/null || pgrep -f "noctalia-shell" > /dev/null; then
    pkill -x "qs"
    pkill -f "noctalia-shell"
else
    # Launch Noctalia
    uwsm app -- env QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 QT_FONT_DPI=96 qs -c noctalia-shell &
fi
