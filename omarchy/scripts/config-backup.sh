#!/bin/bash

# --- Configuration ---
SSD_MOUNT="/run/media/j5/SSD_BACKUPS"
DEST_ROOT="$SSD_MOUNT/Config-Backups"
EXCLUDE_LIST="$HOME/.config/rsync-exclude.txt"

# Define your sources here
# Format: ["Source Path"]="Destination Subfolder"
declare -A SOURCES=(
    ["$HOME/.config/"]="dot-config"
    ["$HOME/Documents/"]="documents"
)

# 1. Check if SSD is mounted
if ! mountpoint -q "$SSD_MOUNT"; then
    echo "❌ SSD_BACKUPS not mounted!"
    exit 1
fi

# 2. Confirmation
echo "📂 Ready to sync the following to $DEST_ROOT:"
for SRC in "${!SOURCES[@]}"; do
    echo "  -> $SRC"
done
echo "🚫 .config ignores managed by: $EXCLUDE_LIST"
echo "------------------------------------------------"
read -p "❓ Proceed with Backup? (y/N): " confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0

# 3. Execution
echo "🚀 Starting backup process..."

for SRC in "${!SOURCES[@]}"; do
    SUBDIR="${SOURCES[$SRC]}"
    TARGET="$DEST_ROOT/$SUBDIR"

    # Create the subfolder if it doesn't exist
    mkdir -p "$TARGET"

    echo "📦 Syncing $SRC to $SUBDIR..."

    # Logic: Only apply the exclude list to the .config source
    if [[ "$SRC" == *".config/" ]]; then
        rsync -rLtvh --delete --delete-excluded \
            --exclude-from="$EXCLUDE_LIST" \
            --ignore-errors \
            "$SRC" "$TARGET/"
    else
        # Standard sync for Documents (no excludes)
        rsync -rLtvh --delete \
            --ignore-errors \
            "$SRC" "$TARGET/"
    fi
done

sync
echo "------------------------------------------------"
echo "✅ All sources are mirrored to separate folders in $DEST_ROOT"
echo "Done."
