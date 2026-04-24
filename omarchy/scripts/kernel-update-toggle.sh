#!/bin/bash

# --- CONFIGURATION ---
PACMAN_CONF="/etc/pacman.conf"
# Order doesn't strictly matter here, but keeping them paired is clean
PACKAGES_TO_TOGGLE="linux-zen-headers linux-zen linux-headers linux"
# --- END CONFIGURATION ---

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo."
   exit 1
fi

# Check if 'linux-zen' is in the line (our indicator that the "lock" is ON)
if grep -q "^IgnorePkg.*linux-zen\b" "$PACMAN_CONF"; then
    echo "Kernels are currently IGNORED. Enabling for upgrade..."
    cp "$PACMAN_CONF" "$PACMAN_CONF.bak"

    for pkg in $PACKAGES_TO_TOGGLE; do
        # Use \b for exact word matching so 'linux' doesn't accidentally 
        # mangle 'linux-zen'
        sed -i "s/\b$pkg\b//g" "$PACMAN_CONF"
    done

    # Clean up excess whitespace left behind on the IgnorePkg line
    sed -i "/^IgnorePkg/s/  */ /g; /^IgnorePkg/s/ *= */ = /; /^IgnorePkg/s/ *$//" "$PACMAN_CONF"

    echo -e "${GREEN}SUCCESS:${NC} Kernel packages are now ENABLED for upgrade."
else
    echo "Kernels are currently ENABLED. Re-ignoring..."
    cp "$PACMAN_CONF" "$PACMAN_CONF.bak"

    # Append the full list to the end of the IgnorePkg line
    sed -i "/^IgnorePkg/ s/$/ $PACKAGES_TO_TOGGLE/" "$PACMAN_CONF"
    
    # Final polish to ensure no double spaces
    sed -i "/^IgnorePkg/s/  */ /g" "$PACMAN_CONF"

    echo -e "${YELLOW}SUCCESS:${NC} Kernel packages are now IGNORED."
fi
