#!/bin/bash

# 1. System Log Maintenance
# Keeps journals from bloating; retains only the last 2 days of logs.
sudo journalctl --vacuum-time=2d

# 2. Package Cache Maintenance (The Paccache Way)
# Keeps only the 1 most recent version of installed packages (Safety net).
# Removes all cached versions of uninstalled packages.
if command -v paccache &> /dev/null; then
    sudo paccache -rk1
    sudo paccache -ruk0
    yay -Sc --aur --noconfirm
else
    # Fallback if pacman-contrib isn't installed
    yes | sudo pacman -Sc
fi

# 3. Orphan Removal
# Identifies and removes packages no longer needed as dependencies.
ORPHANS_LIST=$(pacman -Qtdq)
if [ -n "$ORPHANS_LIST" ]; then
    ORPHANS_COUNT=$(echo "$ORPHANS_LIST" | wc -w)
    sudo pacman -Rns $ORPHANS_LIST --noconfirm
    CLEAN_MSG="Cleaned $ORPHANS_COUNT orphans."
else
    CLEAN_MSG="No orphans found."
fi

# 4. UI & Browser Deep Clean
# Prevents Brave stuttering and keeps the thumbnail cache lean.
rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/GPUCache"/*
rm -rf "$HOME/.cache/BraveSoftware/Brave-Origin-Beta/Default/Code Cache"/*
find ~/.cache/thumbnails -type f -atime +3 -delete 2>/dev/null

# Final Notification
# Using 'System' icon for the toast notification
notify-send -i system-software-update "Maintenance Complete" "$CLEAN_MSG Logs vacuumed and Brave stutter-fix applied." -t 4000
