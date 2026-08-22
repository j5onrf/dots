#!/bin/bash

# ==============================================================================
# Omarchy v4 — Top Bar Safe Toggle
# ==============================================================================

# 1. Resolve State Directory (XDG Compliant)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles"
mkdir -p "$STATE_DIR"

TOGGLE_FILE="$STATE_DIR/bar-off"

# Helper for notifications
send_notify() {
    local title="$1"
    local msg="$2"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$msg" -a "omarchy" -t 1500
    fi
}

# 2. Flip toggle state
if [ -f "$TOGGLE_FILE" ]; then
    rm -f "$TOGGLE_FILE"
    send_notify "Omarchy" "Top bar enabled"
else
    touch "$TOGGLE_FILE"
    send_notify "Omarchy" "Top bar disabled"
fi

# 3. Refresh Omarchy Shell
if command -v omarchy-shell >/dev/null 2>&1; then
    omarchy-shell reload-config 2>/dev/null || omarchy-shell -q omarchy.indicators refresh 2>/dev/null || true
elif pgrep -f "/usr/share/omarchy/shell" >/dev/null 2>&1; then
    if command -v uwsm >/dev/null 2>&1; then
        uwsm app -- omarchy-shell reload-config 2>/dev/null || true
    fi
fi

exit 0
