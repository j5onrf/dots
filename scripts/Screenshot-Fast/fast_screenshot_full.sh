# fast_screenshot_full.sh
#!/bin/sh
OUT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$OUT_DIR"
FILE_PATH="$OUT_DIR/FullScreen-$(date +"%Y-%m-%d_%H-%M-%S").png"
if grim - | tee "$FILE_PATH" | wl-copy; then
    notify-send "Screenshot" "Screen saved to $FILE_PATH and copied." -t 2000
else
    notify-send "Screenshot Failed" "Screen capture error." -t 3000
fi
