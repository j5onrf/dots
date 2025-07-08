# Border Gradients
![FullScreen-2025-07-07_19-30-28](https://github.com/user-attachments/assets/918430a6-56c5-4bcd-8117-6841ba0995df)
![FullScreen-2025-07-07_21-04-08](https://github.com/user-attachments/assets/b1bf07f1-e88d-4225-aed8-58e5aec6047b)

`````
general {
    border_size = 2
    gaps_in = 5
    gaps_out = 10

    # MODIFIED: Uses an 8-point gradient to place a color at each corner and make
    # the space between them transparent.
    col.active_border = $primary rgba(00000000) $primary rgba(00000000) $primary rgba(00000000) $primary rgba(00000000) 45deg

    # MODIFIED: Does the same for inactive windows using $outline color.
    col.inactive_border = $outline rgba(00000000) $outline rgba(00000000) $outline rgba(00000000) $outline rgba(00000000) 45deg
}
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
