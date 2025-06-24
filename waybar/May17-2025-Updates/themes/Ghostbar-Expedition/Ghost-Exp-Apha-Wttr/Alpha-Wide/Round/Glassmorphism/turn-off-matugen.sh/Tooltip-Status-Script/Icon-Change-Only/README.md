    ```jsonc
    
    "custom/wallpaper": {
        "exec": "~/.config/hypr/scripts/get_wallpaper_status.sh",
        "return-type": "json",
        "interval": "once",
        "signal": 1, 
        
        "tooltip": false, // <-- SET THIS TO FALSE
        
        // Your click handlers remain exactly the same
        "on-click": "waypaper",
        "on-click-right": "~/.config/hypr/scripts/wallpaper-effects.sh",
        "on-click-middle": "~/.config/hypr/scripts/turn-off-matugen.sh"
    },
    
    ```

### Why This Works

*   The script is now much simpler. It just checks for the lock file and prints one of two simple JSON objects, each containing only a `"text"` field with the appropriate icon.
*   The Waybar config is updated to reflect this by disabling the tooltip.
*   The event-driven system (`interval: once` + `signal: 1`) remains the same, so it's still perfectly efficient and uses no CPU while idle.

This new setup achieves your goal of a dynamic icon without the added complexity of the tooltip.
