#!/bin/bash

# 1. Ask for a custom label
echo -n "Enter snapshot label: "
read LABEL

# 2. Ask if this should be pinned
echo -n "Pin this snapshot? (y/N): "
read PIN

# 3. Handle empty labels
if [ -z "$LABEL" ]; then
    LABEL="manual"
fi

# 4. Format description (Keeping it clean for Limine/Snapper)
DATE_STR=$(date +%Y-%m-%d)
DESC="Manual-${DATE_STR}-${LABEL// /-}"

# 5. Create Snapshot based on Pin choice
if [[ "$PIN" =~ ^[Yy]$ ]]; then
    # Add 'PIN' to the end so the main label shows first
    FINAL_DESC="${DESC}-PIN"
    sudo snapper create -t single -d "$FINAL_DESC" --read-only
    echo -e "\n📌 Snapshot PINNED (Excluded from auto-cleanup)."
else
    sudo snapper create -t single -d "$DESC" -c number --read-only
fi

# 6. Run cleanup
sudo snapper cleanup number

# 7. Sync to Limine
echo "🔄 Updating Limine boot menu..."
sudo limine-snapper-sync

# 8. Show result
echo -e "\n✅ Process Complete"
echo "--------------------------------------------------"
sudo snapper list | tail -n 8
