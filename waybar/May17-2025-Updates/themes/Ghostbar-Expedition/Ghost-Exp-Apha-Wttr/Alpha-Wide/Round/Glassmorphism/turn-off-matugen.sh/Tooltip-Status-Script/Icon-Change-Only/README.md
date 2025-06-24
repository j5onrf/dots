---

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
