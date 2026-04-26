#!/bin/bash

# 1. Clean pacman cache (Pipes 'yes' to handle all prompts)
yes | sudo pacman -Sc

# 2. Clean AUR cache
yay -Sc --aur --noconfirm

# 3. Check for and remove orphans
ORPHANS_LIST=$(pacman -Qtdq)
if [ -n "$ORPHANS_LIST" ]; then
    ORPHANS_COUNT=$(echo "$ORPHANS_LIST" | wc -w)
    sudo pacman -Rns $ORPHANS_LIST --noconfirm
    CLEAN_MSG="Cleaned $ORPHANS_COUNT orphans and cleared old cache."
else
    CLEAN_MSG="Old cache cleared. No orphans found."
fi

# 4. Brave-Origin-Beta Maintenance (Prevents stuttering)
rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/GPUCache"/*
rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/Code Cache"/*

# Final Notification
notify-send "System Maintenance" "$CLEAN_MSG Browser stutter-fix applied." -t 3000
