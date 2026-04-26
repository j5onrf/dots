#!/bin/bash

# 1. Ask for a custom label
echo -n "Enter snapshot label: "
read LABEL

# 2. Handle empty labels (default to 'manual')
if [ -z "$LABEL" ]; then
    LABEL="manual"
fi

# 3. Format the description
DESC="Manual-$(date +%Y-%m-%d)-${LABEL// /-}"

# 4. Create the snapshot with the 5-limit rule
sudo snapper create -t single -d "$DESC" -c number --read-only

# 5. Force the cleanup so the list stays at 5
sudo snapper cleanup number

# 6. Show the result
echo -e "\n✅ Snapshot created: $DESC"
echo "--------------------------------------------------"
sudo snapper list | tail -n 7
