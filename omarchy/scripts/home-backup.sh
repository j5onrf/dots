#!/bin/bash

# Configuration
SSD_MOUNT="/run/media/j5/SSD_BACKUPS"
DEST="$SSD_MOUNT/Home-Snapshots"
NVME_SNAP_DIR="/home/.snapshots"

# 1. Check if SSD is mounted
if ! mountpoint -q "$SSD_MOUNT"; then
    echo "❌ SSD_BACKUPS not mounted!"
    exit 1
fi

# Ensure destination exists
sudo mkdir -p "$DEST"

# 2. Pre-Backup Cleanup
echo "🧹 Cleaning temporary files (Cache/Trash)..."
rm -rf ~/.cache/*
rm -rf ~/.local/share/Trash/*

# 3. Confirmation & Sudo Refresh
echo "📸 Ready to snapshot /home and beam to SSD..."
read -p "❓ Proceed with Backup? (y/N): " confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0

sudo -v

# 4. Create a fresh read-only snapshot
NEW_ID=$(snapper -c home create -d "Incremental $(date +%Y%m%d)" --type single -p)
echo "📦 New Snapshot #$NEW_ID created on NVMe."

# 5. Identify the Anchor (Most recent snapshot BEFORE the one we just made)
# We filter out '0' because it's not a valid parent for btrfs send
PREV_ID=$(snapper -c home list --type single | awk '$1 ~ /^[0-9]+$/ && $1 < '"$NEW_ID"' {print $1}' | tail -n 1)

# 6. Check if the SSD actually has any snapshots to compare against
SSD_EMPTY=$(ls -A "$DEST" | wc -l)

# 7. Send to SSD
SUCCESS=false
if [ "$SSD_EMPTY" -gt 0 ] && [ -n "$PREV_ID" ]; then
    echo "🚀 Beaming INCREMENTAL changes (Parent: #$PREV_ID) to SSD..."
    if sudo btrfs send -p "$NVME_SNAP_DIR/$PREV_ID/snapshot" "$NVME_SNAP_DIR/$NEW_ID/snapshot" | sudo btrfs receive "$DEST"; then
        SUCCESS=true
    fi
else
    echo "🚀 Performing FULL send (First backup or no parent on SSD)..."
    if sudo btrfs send "$NVME_SNAP_DIR/$NEW_ID/snapshot" | sudo btrfs receive "$DEST"; then
        SUCCESS=true
    fi
fi

# 8. Cleanup & Finish
if [ "$SUCCESS" = true ]; then
    SNAP_NAME="Home-$(date +%Y%m%d-%H%M%S)"
    sudo mv "$DEST/snapshot" "$DEST/$SNAP_NAME"
    echo "✅ Success: $SNAP_NAME created on SSD."
    
    # Remove the OLD anchor from NVMe, keep the NEW one
    if [ -n "$PREV_ID" ]; then
        echo "🗑️ Removing old anchor #$PREV_ID from NVMe..."
        snapper -c home delete "$PREV_ID"
    fi
else
    echo "🚨 Transfer failed! You may need to delete #$NEW_ID manually."
    exit 1
fi

# 9. Retention (Keep 5 on SSD)
ls -dt "$DEST"/Home-* 2>/dev/null | tail -n +6 | xargs -I {} sudo btrfs subvolume delete "{}"

sync
echo "Done. Current anchor on NVMe is #$NEW_ID."
