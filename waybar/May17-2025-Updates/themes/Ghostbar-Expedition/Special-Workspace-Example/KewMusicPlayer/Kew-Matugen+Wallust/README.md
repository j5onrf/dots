# Dynamic Kew Theming with Matugen & Wallust

![FullScreen-2025-06-14_10-13-30](https://github.com/user-attachments/assets/43c754bc-56df-4b13-b841-db2b9f8b2671)

This project provides a robust method to dynamically theme `kewmusicplayer` in a Hyprland environment. It leverages `matugen` to define color *roles* (like "primary accent") and `wallust` to provide a rich, wallpaper-based terminal color palette for `kitty`.

The result is a `kew` instance where the text colors intelligently match the most appropriate color from your terminal's actual theme.

### Disclaimer: Visualizer Color

Please note that this method themes all the **text elements** of `kewmusicplayer`. The color of the visualizer (the EQ bars) is a hardcoded feature within `kew` and **cannot be changed by this script**. It will almost always render as white/gray.

## How It Works (The Smart Way)

This method is superior to simply mapping to a generic 8-color palette. Here’s the logic:

1.  **Wallust sets the stage:** `wallust` runs and generates a full color scheme for `kitty` (in `colors-wallust.conf`), giving you beautiful, wallpaper-aware terminal colors (color0 through color7).
2.  **Matugen defines the roles:** `matugen` runs and generates its own palette (in `colors.css`), defining the *semantic meaning* of colors (e.g., `primary` should be a specific shade of purple, `on_background` should be a light text color).
3.  **The script finds the best match:** A Python script reads the `primary` hex code from `matugen`. It then compares this color to all 8 of the rich `wallust` colors available in `kitty` and finds the closest match.
4.  **The script sets the index:** It tells `kewrc` to use the *index* of that best-matched color (e.g., "use `color5` for the primary accent").

This ensures that `kew`'s accent color is one of the *actual*, beautiful colors from your theme, solving the problem of a nice purple wallpaper turning into a generic white or magenta highlight.

## Prerequisites

*   **Hyprland**
*   **`matugen`** (configured to output to `~/.config/waybar/colors.css` or similar)
*   **`wallust`** (configured to generate a `kitty` theme at `~/.config/kitty/colors-wallust.conf`)
*   **`kitty`** as your terminal
*   **`kewmusicplayer`**
*   **`python3`**
*   A wallpaper script that runs both `matugen` and `wallust`.

## Setup

### Step 1: Create the Color Matching Script

This Python script is the "brain" of the operation. It finds the best color match between the `matugen` role and the `wallust` palette.

**Create the file `~/.config/kew/find_closest_palette_color.py`:**
```python
import sys

def hex_to_rgb(hex_color):
    """Converts a hex color string (e.g., '#RRGGBB') to an (R, G, B) tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def color_distance(rgb1, rgb2):
    """Calculates the Euclidean distance between two RGB colors."""
    return sum([(c1 - c2) ** 2 for c1, c2 in zip(rgb1, rgb2)]) ** 0.5

def find_best_match_index(target_hex, palette_hex_list):
    """
    Finds the index of the color in the palette that is closest to the target color.
    """
    try:
        target_rgb = hex_to_rgb(target_hex)
        palette_rgb_list = [hex_to_rgb(c) for c in palette_hex_list]
    except (ValueError, IndexError):
        return -1 # Handle cases with invalid hex codes

    closest_index = -1
    min_distance = float('inf')

    for i, palette_rgb in enumerate(palette_rgb_list):
        dist = color_distance(target_rgb, palette_rgb)
        if dist < min_distance:
            min_distance = dist
            closest_index = i
            
    return closest_index

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1) # Exit if not enough arguments

    target_color_hex = sys.argv[1]
    palette_colors_hex = sys.argv[2:]

    best_index = find_best_match_index(target_color_hex, palette_colors_hex)
    
    if best_index != -1:
        print(best_index)
    else:
        sys.exit(1) # Exit with an error if something went wrong
```
**Make it executable:**
```bash
chmod +x ~/.config/kew/find_closest_palette_color.py
```

### Step 2: Create the Main Update Script

This Bash script orchestrates the whole process.

**Create the file `~/.config/hypr/scripts/update_kew_colors.sh`:**
```bash
#!/bin/bash

# --- Configuration ---
# Path to matugen generated colors.css (for color roles like 'primary')
MATUGEN_COLORS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/colors.css"

# Path to the wallust generated Kitty color config file
KITTY_COLORS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/colors-wallust.conf"

# Path to your kewrc config file
KEWRC_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kew/kewrc"

# Path to the Python matching script
PYTHON_SCRIPT_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/kew/find_closest_palette_color.py"


# --- Main Logic ---
# Exit if the required color files don't exist
if ! [ -f "$MATUGEN_COLORS_FILE" ] || ! [ -f "$KITTY_COLORS_FILE" ]; then
    echo "Error: Required color files from matugen or kitty not found." >&2
    exit 1
fi

# 1. Read the 8 ANSI color hex codes from the Kitty config file
palette=()
for i in {0..7}; do
    hex=$(grep -m 1 "^\s*color${i}\s" "$KITTY_COLORS_FILE" | awk '{print $2}')
    palette+=("$hex")
done

# Check if we successfully read the palette
if [ ${#palette[@]} -ne 8 ]; then
    echo "Error: Could not read the 8-color palette from the kitty config." >&2
    exit 1
fi

# 2. Get the target hex code for a specific role from matugen
get_matugen_hex() { grep -m 1 "@define-color $1" "$MATUGEN_COLORS_FILE" | awk '{print $NF}' | tr -d ';'; }

# 3. Find the best palette index for each role using the Python script
find_best_index() {
    local role_name="$1"
    local fallback_index="$2"
    local target_hex=$(get_matugen_hex "$role_name")
    
    if [ -n "$target_hex" ]; then
        python3 "$PYTHON_SCRIPT_PATH" "$target_hex" "${palette[@]}" 2>/dev/null || echo "$fallback_index"
    else
        echo "$fallback_index"
    fi
}

# 4. Map roles to kew colors
KEW_LOGO_COLOR=$(find_best_index "on_background" 7)   # Text color, fallback to white (color7)
KEW_ARTIST_COLOR=$(find_best_index "primary" 6)       # Primary accent, fallback to cyan (color6)
KEW_TITLE_COLOR=$(find_best_index "primary" 6)         # Primary accent, fallback to cyan (color6)
KEW_ENQUEUED_COLOR=$(find_best_index "secondary" 2)   # Secondary accent, fallback to green (color2)


# 5. Update kewrc file
sed -i '/^useConfigColors=/c\useConfigColors=1' "$KEWRC_FILE"
sed -i "/^color=/c\color=$KEW_LOGO_COLOR" "$KEWRC_FILE"
sed -i "/^artistColor=/c\artistColor=$KEW_ARTIST_COLOR" "$KEWRC_FILE"
sed -i "/^titleColor=/c\titleColor=$KEW_TITLE_COLOR" "$KEWRC_FILE"
sed -i "/^enqueuedColor=/c\enqueuedColor=$KEW_ENQUEUED_COLOR" "$KEWRC_FILE"

echo "Kew colors in '$KEWRC_FILE' updated by matching matugen roles to the kitty/wallust palette."
exit 0
```
**Make it executable:**
```bash
chmod +x ~/.config/hypr/scripts/update_kew_colors.sh
```

### Step 3: Configure `kewrc`

Ensure `kew` is set to use the colors from its configuration file.

**Open `~/.config/kew/kewrc` and make sure the `[colors]` section looks like this:**
```ini
[colors]
useConfigColors=1
# The values below will be overwritten by the script
color=7
artistColor=6
titleColor=6
enqueuedColor=2
```

### Step 4: Integrate into Your Wallpaper Script

Finally, add the call to your `update_kew_colors.sh` script inside your main `$HOME/.config/hypr/scripts/wallpaper.sh`. Place it after both `matugen` and `wallust` have finished running.

**Example addition to `wallpaper.sh`:**
```bash
# --- Add this section to update Kew colors ---
KEW_UPDATE_SCRIPT="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/update_kew_colors.sh"
if [ -f "$KEW_UPDATE_SCRIPT" ]; then
    echo ":: Updating Kewmusicplayer colors..."
    # The config file is updated silently in the background. Kew will detect the change automatically.
    bash "$KEW_UPDATE_SCRIPT" &
else
    echo ":: Warning: Kew color update script not found at $KEW_UPDATE_SCRIPT" >&2
fi
# --- End of Kew color update section ---
```

## Usage

1.  Change your wallpaper using the script that triggers this whole process.
2.  If `kew` is running, you will get a notification.
3.  Restart `kew` to see the new, accurately matched colors:
    ```bash
    pkill kew && kew
    ```
