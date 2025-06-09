#!/bin/sh

# Define the output directory
OUT_DIR="$HOME/Pictures/Screenshots"

# Ensure the output directory exists
mkdir -p "$OUT_DIR"

# Define the file path with a timestamp
FILE_PATH="$OUT_DIR/Region-$(date +"%Y-%m-%d_%H-%M-%S").png"

# Execute the screenshot command
if grim -g "$(slurp)" - | tee "$FILE_PATH" | wl-copy; then
    notify-send "Screenshot" "Region saved to $FILE_PATH and copied." -t 2000
else
    notify-send "Screenshot Failed" "Region capture error." -t 3000
fi
