#!/bin/bash

# Minimal Waybar Theme Switcher
# Edited by j5onrf (12-11-2024)
# Script currently only works with custom themes*

themes_path="$HOME/.config/waybar/themes"

# Generate theme list
listThemes=$(find "$themes_path" -mindepth 1 -maxdepth 1 -type d | awk -F'/' '{print $NF}')

# Show Rofi dialog
choice=$(echo -e "$listThemes" | rofi -dmenu -replace -i -config ~/.config/rofi/config-themes.rasi -no-show-icons -width 30 -p "Select Theme")

# Apply selected theme
if [ -n "$choice" ]; then
    echo "$choice" > "$HOME/.config/ml4w/settings/waybar-theme.sh"
    ~/.config/waybar/launch.sh
    notify-send "Waybar Theme Changed" "$choice"
fi

