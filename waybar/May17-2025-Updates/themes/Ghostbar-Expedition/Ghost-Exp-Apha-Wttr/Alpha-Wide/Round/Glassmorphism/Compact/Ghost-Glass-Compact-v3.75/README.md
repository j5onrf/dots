# Border Gradients
![FullScreen-2025-07-07_19-30-28](https://github.com/user-attachments/assets/918430a6-56c5-4bcd-8117-6841ba0995df)

`````
general {
    border_size = 2
    gaps_in = 5
    gaps_out = 10

    #(1) Uses an 7-point gradient
    col.active_border = $primary $primary rgba(00000000) $primary $primary rgba(00000000) $primary 30deg
    col.inactive_border = $outline $outline rgba(00000000) $outline $outline rgba(00000000) $outline 30deg
}
`````
`````
    #(2) 5-point gradient. All corners
    col.active_border = $primary rgba(00000000) $primary rgba(00000000) $primary 30deg
    col.inactive_border = $outline rgba(00000000) $outline rgba(00000000) $outline 30deg
    
`````
# toggle_float_resize.sh
`````
bind = $mainMod, T, exec, ~/.config/hypr/scripts/toggle_float_resize.sh                     # Toggle active windows into floating mode
`````

`````
#!/bin/bash

if hyprctl activewindow -j | jq -e '.floating == false'; then

    read -r mon_width mon_height <<< $(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')

    target_width=$((mon_width * 60 / 100))
    target_height=$((mon_height * 70 / 100))

    hyprctl --batch "\
        dispatch togglefloating; \
        dispatch resizeactive exact $target_width $target_height; \
        dispatch centerwindow"
else
    hyprctl dispatch togglefloating
fi
`````
