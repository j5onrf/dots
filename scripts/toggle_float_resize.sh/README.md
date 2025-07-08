
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
