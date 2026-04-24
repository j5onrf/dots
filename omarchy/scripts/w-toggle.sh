#!/bin/bash

if pgrep -x "waybar" > /dev/null; then
    # --- SHUTDOWN (Clear for Shells) ---
    omarchy-toggle-waybar
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
else
    # --- STARTUP (Back to Omarchy) ---
    # Ensure a clean slate before bringing the bar back
    pkill -9 mako 2>/dev/null
    pkill -9 walker 2>/dev/null
    pkill -9 swayosd-server 2>/dev/null
    sleep 0.1 

    omarchy-toggle-waybar
    uwsm app -- mako &
    uwsm app -- swayosd-server &
    uwsm app -- walker --gapplication-service &
fi
