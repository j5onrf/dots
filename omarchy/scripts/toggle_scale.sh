#!/bin/bash

# 1. Detect monitor and current scale
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
CURRENT_SCALE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')

GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"

if [ "$CURRENT_SCALE" == "2" ] || [ "$CURRENT_SCALE" == "2.00" ]; then
    # --- SWITCHING TO 1x (Workstation Mode) ---
    NEW_SCALE=1
    FONT_VAL="JetBrains Mono 16"
else
    # --- SWITCHING TO 2x (Android Mode) ---
    NEW_SCALE=2
    FONT_VAL="JetBrains Mono 8"
fi

# 2. Apply the monitor scale with your 8-bit preference preserved
hyprctl keyword monitor "$MONITOR, 3440x1440@120, auto, $NEW_SCALE, bitdepth, 8"

# 3. Update the GTK files directly
[ -f "$GTK3_FILE" ] && sed -i "s/^gtk-font-name=.*/gtk-font-name=$FONT_VAL/" "$GTK3_FILE"
[ -f "$GTK4_FILE" ] && sed -i "s/^gtk-font-name=.*/gtk-font-name=$FONT_VAL/" "$GTK4_FILE"

# 4. Force GSettings broadcast (for live-updating apps)
gsettings set org.gnome.desktop.interface font-name "$FONT_VAL"
gsettings set org.gnome.desktop.interface document-font-name "$FONT_VAL"
gsettings set org.gnome.desktop.interface monospace-font-name "$FONT_VAL"
