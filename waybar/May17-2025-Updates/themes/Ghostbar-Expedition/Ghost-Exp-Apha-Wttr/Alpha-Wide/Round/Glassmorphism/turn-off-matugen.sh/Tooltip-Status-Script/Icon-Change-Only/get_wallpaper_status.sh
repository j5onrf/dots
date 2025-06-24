#!/bin/bash

# Define the path for the lock file
LOCK_FILE="$HOME/.config/ml4w/cache/matugen_lock"

# Check if the lock file exists
if [ -f "$LOCK_FILE" ]; then
    # If locked, output the JSON for the "locked" icon
    # The '' character is a common lock icon (\uf023)
    echo '{"text": ""}'
else
    # If not locked, output the JSON for the normal wallpaper icon
    # The '' character is your wallpaper icon (\uf03e)
    echo '{"text": ""}'
fi