#!/bin/bash

# Define the options
options="[G1] Waybar / Omarchy
[G2] Veo UI
[G3] Shell-Fusion
[G4] Caelestia
[G5] Noctalia
[G6] DankMaterialShell"

# Get choice - Removed the --theme flag to match walker-windows behavior
choice=$(echo -e "$options" | /usr/bin/walker --dmenu | xargs)

# Exit if cancelled
[ -z "$choice" ] && exit 0

# Selection Logic
if [[ "$choice" == *"G1"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/w-toggle.sh" &
elif [[ "$choice" == *"G2"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/veo-toggle.sh" &
elif [[ "$choice" == *"G3"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/f-toggle.sh" &
elif [[ "$choice" == *"G4"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/c-toggle.sh" &
elif [[ "$choice" == *"G5"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/n-toggle.sh" &
elif [[ "$choice" == *"G6"* ]]; then
    bash "/home/j5/.config/hypr/Scripts/d-toggle.sh" &
fi
