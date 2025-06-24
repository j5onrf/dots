#!/bin/bash
    
# Define the path for the lock file
LOCK_FILE="$HOME/.config/ml4w/cache/matugen_lock"
    
# Check if the lock file exists
if [ -f "$LOCK_FILE" ]; then
    # If it exists, Matugen is currently DISABLED. We will re-enable it.
    rm "$LOCK_FILE"
    notify-send -i "preferences-desktop-wallpaper" "Matugen Theming" "ENABLED" -t 3000
else
    # If it does not exist, Matugen is currently ENABLED. We will disable it.
    touch "$LOCK_FILE"
    notify-send -i "emblem-system-readonly" "Matugen Theming" "DISABLED" -t 3000
fi
    
# Reload Waybar to apply color changes to other modules if theming is re-enabled
# killall -SIGUSR2 waybar
