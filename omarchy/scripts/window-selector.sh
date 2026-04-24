#!/bin/bash

# --- Veo Window Selector v0.1.2 ---

# Dependency Check
if ! command -v jq &> /dev/null || ! command -v fzf &> /dev/null; then
    notify-send "Veo Error" "Please install 'jq' and 'fzf' to use the window selector."
    exit 1
fi

# 1. Get windows
# 2. Filter OUT the window with title "floating_kitty"
# 3. Format with tabs and enable wrapping
selection=$(hyprctl clients -j | jq -r '.[] | select(.title != "floating_kitty") | "\(.class)\t\(.address)"' | \
    fzf --prompt="󱂬 Switch to: " \
        --layout=reverse \
        --border=none \
        --cycle \
        --with-nth=1)

if [ -n "$selection" ]; then
    # Extract the address (column 2) and focus
    addr=$(echo "$selection" | cut -f2)
    hyprctl dispatch focuswindow address:"$addr"
fi
