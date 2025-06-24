#!/bin/bash

# Define the path for the lock file
LOCK_FILE="$HOME/.config/ml4w/cache/matugen_lock"

# The main icon never changes
ICON="" # Your \uf03e wallpaper icon

# Check if the lock file exists and set the tooltip text accordingly
if [ -f "$LOCK_FILE" ]; then
    # If locked, set the tooltip to "ACTIVE"
    TOOLTIP_TEXT="Theme-Lock: ACTIVE"
else
    # If not locked, set the tooltip to "INACTIVE"
    TOOLTIP_TEXT="Theme-Lock: INACTIVE"
fi

# Print the JSON output that Waybar will use.
# This sets both the main text (our icon) and the tooltip text.
printf '{"text": "%s", "tooltip": "%s"}\n' "$ICON" "$TOOLTIP_TEXT"