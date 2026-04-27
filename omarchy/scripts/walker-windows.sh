#!/bin/bash

# 1. Get Windows (Slim/Fast version)
windows=$(hyprctl clients -j | jq -r '.[] | "\(.class) | \(.title) | \(.address)"')

# 2. Launch Walker (NO --theme flag)
# By removing the flag, Walker will use the path defined in your config.toml
selection=$(echo -e "$windows" | /usr/bin/walker --dmenu)

# 3. Focus
if [ -n "$selection" ]; then
    addr=${selection##*| }
    hyprctl dispatch focuswindow address:"$addr"
fi
