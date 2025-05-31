#!/bin/bash

# This script themes a random Fastfetch logo using colors from Matugen's Waybar CSS.
# It should be run AFTER Matugen has updated the colors.css file.

# --- Configuration ---
BASE_LOGO_DIR="$HOME/.config/fastfetch/logos/originals"
MATUGEN_WAYBAR_CSS_FILE="$HOME/.config/waybar/colors.css"
THEMED_LOGO_OUTPUT_PATH="$HOME/.config/fastfetch/logos/current_random_themed_logo.png" # Fixed output for Fastfetch

# --- Matugen Color Names to Use (from colors.css) ---
MATUGEN_COLOR_NAME_FOR_DARK_PARTS="surface_container_highest" # Example
MATUGEN_COLOR_NAME_FOR_LIGHT_PARTS="primary"               # Example

# --- Helper function to extract color ---
get_matugen_css_color() {
    local color_name_css="$1"
    local css_file="$2"
    local default_color="$3" 

    if [ ! -f "$css_file" ]; then
        echo "$default_color"
        # Send error to stderr so it doesn't get captured by command substitution if used incorrectly
        echo "Error: Matugen CSS file not found: $css_file. Using default for $color_name_css." >&2
        return 1 # Indicate failure
    fi

    local color_value
    color_value=$(grep -E "^\s*@define-color\s+${color_name_css}\s+" "$css_file" | awk '{print $3}' | sed 's/;//')

    if [[ -n "$color_value" ]] && [[ "$color_value" =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]; then
        echo "$color_value"
        return 0 # Indicate success
    else
        echo "$default_color"
        echo "Warning: Color '$color_name_css' not found or invalid in $css_file. Found: '$color_value'. Using default." >&2
        return 1 # Indicate failure
    fi
}

# --- Main Logic ---
echo "--- Running theme_fastfetch_logo.sh ---" >&2 # Debugging

# 1. Check if Matugen CSS file exists
if [ ! -f "$MATUGEN_WAYBAR_CSS_FILE" ]; then
    echo "Error: Matugen CSS file '$MATUGEN_WAYBAR_CSS_FILE' not found. Cannot theme logo." >&2
    exit 1
fi
echo "DEBUG: Matugen CSS file timestamp:" >&2
ls -l "$MATUGEN_WAYBAR_CSS_FILE" >&2

# 2. Read Theme Colors from Matugen CSS
# For +level-colors, black is replaced by the first, white by the second.
TARGET_FOR_BLACK_REGIONS=$(get_matugen_css_color "$MATUGEN_COLOR_NAME_FOR_DARK_PARTS" "$MATUGEN_WAYBAR_CSS_FILE" "#000000")
dark_color_success=$?
TARGET_FOR_WHITE_REGIONS=$(get_matugen_css_color "$MATUGEN_COLOR_NAME_FOR_LIGHT_PARTS" "$MATUGEN_WAYBAR_CSS_FILE" "#FFFFFF")
light_color_success=$?

if [ $dark_color_success -ne 0 ] || [ $light_color_success -ne 0 ]; then
    echo "Error: Failed to extract one or both theme colors. Using original logo for safety." >&2
    # As a fallback, copy any existing logo or a default to the target location
    # This ensures Fastfetch doesn't break if it expects the file.
    find "$BASE_LOGO_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) -print -quit | head -n 1 | xargs -I {} cp {} "$THEMED_LOGO_OUTPUT_PATH"
    exit 1
fi
echo "DEBUG: Using Matugen colors -> Dark parts: $TARGET_FOR_BLACK_REGIONS, Light parts: $TARGET_FOR_WHITE_REGIONS" >&2


# 3. Randomly Select a Base Logo
if [ ! -d "$BASE_LOGO_DIR" ]; then
    echo "Error: Base logo directory not found: $BASE_LOGO_DIR" >&2
    exit 1 
fi
mapfile -t available_logos < <(find "$BASE_LOGO_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))
if [ ${#available_logos[@]} -eq 0 ]; then
    echo "Error: No logos found in $BASE_LOGO_DIR" >&2
    exit 1 
fi
random_index=$((RANDOM % ${#available_logos[@]}))
SELECTED_BASE_LOGO_PATH="${available_logos[$random_index]}"
echo "DEBUG: Selected base logo for theming: $SELECTED_BASE_LOGO_PATH" >&2

# 4. ImageMagick: Re-color the selected logo, preserving alpha
# Temporary files for ImageMagick processing
ALPHA_CHANNEL_LOGO="/tmp/fastfetch_logo_alpha_$$.png" # Add PID for uniqueness
COLORIZED_OPAQUE_LOGO="/tmp/fastfetch_logo_colorized_opaque_$$.png"

# a. Extract alpha
if ! magick "$SELECTED_BASE_LOGO_PATH" -alpha extract "$ALPHA_CHANNEL_LOGO"; then
    echo "Error: Failed to extract alpha channel from $SELECTED_BASE_LOGO_PATH." >&2
    cp "$SELECTED_BASE_LOGO_PATH" "$THEMED_LOGO_OUTPUT_PATH" 
    rm -f "$ALPHA_CHANNEL_LOGO" "$COLORIZED_OPAQUE_LOGO" # Ensure cleanup
    exit 1
fi

# b. Create colorized version (will be opaque)
if ! magick "$SELECTED_BASE_LOGO_PATH" \
    -colorspace Gray \
    +level-colors "${TARGET_FOR_BLACK_REGIONS}","${TARGET_FOR_WHITE_REGIONS}" \
    "$COLORIZED_OPAQUE_LOGO"; then
    echo "Error: Failed to colorize logo $SELECTED_BASE_LOGO_PATH." >&2
    cp "$SELECTED_BASE_LOGO_PATH" "$THEMED_LOGO_OUTPUT_PATH"
    rm -f "$ALPHA_CHANNEL_LOGO" "$COLORIZED_OPAQUE_LOGO"
    exit 1
fi

# c. Combine colorized logo with original alpha
if magick "$COLORIZED_OPAQUE_LOGO" "$ALPHA_CHANNEL_LOGO" \
    -alpha off \
    -compose CopyOpacity -composite \
    "$THEMED_LOGO_OUTPUT_PATH"; then
    echo "Themed logo saved: $THEMED_LOGO_OUTPUT_PATH" >&2
    ls -l "$THEMED_LOGO_OUTPUT_PATH" >&2 # Show timestamp of final themed logo
else
    echo "Error: Failed to re-apply alpha channel to themed logo." >&2
    cp "$SELECTED_BASE_LOGO_PATH" "$THEMED_LOGO_OUTPUT_PATH"
fi

rm -f "$ALPHA_CHANNEL_LOGO" "$COLORIZED_OPAQUE_LOGO"
echo "--- theme_fastfetch_logo.sh finished ---" >&2