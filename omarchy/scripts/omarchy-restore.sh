#!/bin/bash

# --- CONFIGURATION ---
PACMAN_CONF="/etc/pacman.conf"
PACKAGES_TO_IGNORE="linux-zen-headers linux-zen linux-headers linux"

# Determine the actual user's home directory even when running as sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

THEME_SET_FILE="$REAL_HOME/.local/share/omarchy/bin/omarchy-theme-set"
RELOAD_COMMAND="$REAL_HOME/.config/hypr/scripts/f-reload.sh &"
# --- END CONFIGURATION ---

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo (e.g., 'sudo ./omarchy-restore.sh')"
   exit 1
fi

echo "--- STARTING OMARCHY RESTORE ---"

# 1. Restore Pacman Settings
echo "Step 1: Restoring Pacman Config (Kernels + Visuals)..."
if ! grep -q "^IgnorePkg" "$PACMAN_CONF"; then
    sed -i "/^\[options\]/a IgnorePkg =" "$PACMAN_CONF"
fi
sed -i "/^IgnorePkg/ s/=.*/= $PACKAGES_TO_IGNORE/" "$PACMAN_CONF"

# Ensure Color is enabled
if grep -q "^#Color" "$PACMAN_CONF"; then
    sed -i "s/^#Color/Color/" "$PACMAN_CONF"
    echo "✅ Enabled Color"
fi

# Comment out ILoveCandy
if grep -q "^ILoveCandy" "$PACMAN_CONF"; then
    sed -i "s/^ILoveCandy/#ILoveCandy/" "$PACMAN_CONF"
    echo "✅ Commented out ILoveCandy"
fi

echo "✅ Pacman settings restored."

# 2. Patch Theme-Set Script
echo "Step 2: Patching Theme-Set Script..."
if [ -f "$THEME_SET_FILE" ]; then
    if ! grep -q "f-reload.sh" "$THEME_SET_FILE"; then
        sed -i '$a\' "$THEME_SET_FILE"
        echo "$RELOAD_COMMAND" >> "$THEME_SET_FILE"
        echo "✅ Reload command added to $THEME_SET_FILE."
    else
        echo "ℹ️ Reload command already exists."
    fi
else
    echo "❌ Error: Could not find $THEME_SET_FILE (Expected in $REAL_USER's home)"
fi

echo "--- RESTORE COMPLETE ---"
