#!/bin/bash

# 1. Force remove all cached package files (Bypasses IgnorePkg/Pinned bloat)
sudo rm -f /var/cache/pacman/pkg/*.pkg.tar.zst

# 2. Clean the AUR build cache (Keeps ~/.cache/yay lean)
yay -Sc --aur --noconfirm

# 3. Check for and remove orphans
ORPHANS_LIST=$(yay -Qtdq)
if [ -n "$ORPHANS_LIST" ]; then
    ORPHANS_COUNT=$(echo "$ORPHANS_LIST" | wc -w)
    yay -Rns $ORPHANS_LIST --noconfirm
    notify-send "System Maintenance" "Cleaned $ORPHANS_COUNT orphans and wiped cache." -t 3000
else
    notify-send "System Maintenance" "Cache wiped. No orphans found." -t 2000
fi
