#!/bin/bash

sudo journalctl --vacuum-time=2d

if command -v paccache &> /dev/null; then
    sudo paccache -rk1
    sudo paccache -ruk0
    yay -Sc --aur --noconfirm
    rm -rf ~/.cache/yay/*
else
    yes | sudo pacman -Sc
fi

ORPHANS_LIST=$(pacman -Qtdq)
if [ -n "$ORPHANS_LIST" ]; then
    ORPHANS_COUNT=$(echo "$ORPHANS_LIST" | wc -w)
    sudo pacman -Rns $ORPHANS_LIST --noconfirm
    CLEAN_MSG="Cleaned $ORPHANS_COUNT orphans."
else
    CLEAN_MSG="No orphans found."
fi

rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/GPUCache"/*
rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/Code Cache"/*
find ~/.cache/thumbnails -type f -atime +3 -delete 2>/dev/null

notify-send -i system-software-update "Maintenance Complete" "$CLEAN_MSG Logs vacuumed and Brave stutter-fix applied." -t 4000
