`get_wallpaper_status.sh` script.

`turn-off-matugen.sh` script updated.

### Quick Description

This script is a simple status indicator for the Waybar wallpaper module. Its only job is to check if the "Theme-Lock" is active by looking for a specific lock file. It then prints a single line of JSON containing the correct icon and a dynamic tooltip ("ACTIVE" or "INACTIVE") for Waybar to display. This allows the tooltip to reflect the current state instantly without using any CPU on an interval loop.

---
    "custom/wallpaper": {
        "exec": "~/.config/hypr/scripts/get_wallpaper_status.sh",
        "return-type": "json",
        "interval": "once",
        "signal": 1, 
        "tooltip": true,
        "on-click": "waypaper",
        "on-click-right": "~/.config/hypr/scripts/wallpaper-effects.sh",
        "on-click-middle": "~/.config/hypr/scripts/turn-off-matugen.sh"
    },
