#!/bin/bash

WALLUST_COLORS_FILE="$HOME/.config/kitty/colors-wallust.conf"
CAVA_CONFIG_TEMPLATE="$HOME/.config/cava/config_template"
TEMP_CAVA_CONFIG="/tmp/cava_dynamic_config_$$"

GRADIENT_ANSI_COLORS=(
    "color1"
    "color2" 
    "color3" 
    "color4"
    "color5" 
    "color6" 
)

# Adds More Color to Bars
# GRADIENT_ANSI_COLORS=(
 #   "color1"
 #   "color5" 
 #   "color3" 
 #   "color2"
 #   "color6" 
 #   "color4" 
#)

get_hex_for_ansi() {
    local ansi_name="$1"
    local color_line
    color_line=$(grep -E "^\s*${ansi_name}\s+" "$WALLUST_COLORS_FILE")
    if [[ -n "$color_line" ]]; then
        echo "$color_line" | awk '{print $2}'
    else
        echo "#FFFFFF"
    fi
}

cp "$CAVA_CONFIG_TEMPLATE" "$TEMP_CAVA_CONFIG"

for i in "${!GRADIENT_ANSI_COLORS[@]}"; do
    ansi_color_name="${GRADIENT_ANSI_COLORS[$i]}"
    hex_value=$(get_hex_for_ansi "$ansi_color_name")
    placeholder="__GRADIENT_COLOR_$((i+1))__"
    # This sed command correctly adds single quotes around the hex value
    sed -i "s/$placeholder/'$hex_value'/g" "$TEMP_CAVA_CONFIG"
done

trap 'rm -f "$TEMP_CAVA_CONFIG"; echo "Cava exited, cleaned up $TEMP_CAVA_CONFIG"; exit' SIGINT SIGTERM EXIT

cava -p "$TEMP_CAVA_CONFIG"

