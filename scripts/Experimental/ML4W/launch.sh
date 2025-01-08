#!/bin/bash

# Minimal Waybar Theme launch
# Edited by j5onrf (12-11-2024)
# Script currently only works with custom themes*

# Quit all running Waybar instances
killall waybar
pkill waybar
sleep 0.5

# Read the current theme path
THEME_FILE="$HOME/.config/ml4w/settings/waybar-theme.sh"
[ -f "$THEME_FILE" ] && themestyle=$(<"$THEME_FILE")

# Extract base theme
IFS=';' read -r baseTheme _ <<< "$themestyle"
echo ":: Theme: $baseTheme"

# Launch Waybar with the selected theme
THEME_PATH="$HOME/.config/waybar/themes/$baseTheme"
CONFIG_FILE="config"
STYLE_FILE="style.css"

[ ! -f "$HOME/.cache/waybar-disabled" ] && waybar -c "$THEME_PATH/$CONFIG_FILE" -s "$THEME_PATH/$STYLE_FILE" &
