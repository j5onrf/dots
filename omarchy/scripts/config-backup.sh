#!/bin/bash

# --- Configuration ---
SSD_MOUNT="/run/media/j5/SSD_BACKUPS"
DEST_ROOT="$SSD_MOUNT/Config-Backups"
EXCLUDE_LIST="$HOME/.config/rsync-exclude.txt"

declare -A SOURCES=(
    ["$HOME/.config/"]="dot-config"
    ["$HOME/Documents/"]="documents"
)

# 1. Check if SSD is mounted and WRITABLE
if ! mountpoint -q "$SSD_MOUNT"; then
    echo "❌ SSD_BACKUPS not mounted!"
    exit 1
elif [ ! -w "$SSD_MOUNT" ]; then
    echo "❌ SSD_BACKUPS is mounted but NOT writable!"
    exit 1
fi

# 2. Confirmation
echo "📂 Ready to mirror the following to $DEST_ROOT:"
for SRC in "${!SOURCES[@]}"; do
    echo "  -> $SRC"
done
echo "🚫 Excludes managed by: $EXCLUDE_LIST"
echo "------------------------------------------------"
read -p "❓ Proceed with Backup? (y/N): " confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0

# 3. Execution
echo "🚀 Starting backup process..."

for SRC in "${!SOURCES[@]}"; do
    SUBDIR="${SOURCES[$SRC]}"
    TARGET="$DEST_ROOT/$SUBDIR"

    # Create target if it doesn't exist
    mkdir -p "$TARGET"

    echo "📦 Syncing $SRC..."

    # Flags:
    # -a: Archive mode (preserves symlinks, permissions, times)
    # -v: Verbose
    # -P: Show progress bar and allow resumed transfers
    # -h: Human-readable numbers
    COMMON_FLAGS="-avPh --delete --ignore-errors"

    if [[ "$SRC" == *".config/" ]]; then
        rsync $COMMON_FLAGS --delete-excluded --exclude-from="$EXCLUDE_LIST" "$SRC" "$TARGET/"
    else
        rsync $COMMON_FLAGS "$SRC" "$TARGET/"
    fi
done

sync # Ensure data is physically flushed to the NVMe/SSD
echo "------------------------------------------------"
echo "✅ Backup Complete."
