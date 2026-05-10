#!/bin/bash
# --- NOCTALIA TOGGLE (Robust v4 Engine - Notification Sync) ---

# Configuration
NOCTALIA_BIN="/usr/local/bin/qs"
NOCTALIA_TARGET="noctalia" # The package/config name

# --- SHUTDOWN LOGIC ---
if pgrep -x "qs" > /dev/null; then
    # Kill Noctalia
    pkill -x "qs"
    
    # 1. Restore Mako as the fallback notification daemon
    # This ensures you still get alerts when Noctalia is hidden
    uwsm app -- mako & 
    
    # Clean up any hanging notifications
    makoctl dismiss -a 2>/dev/null
    
    # Wait for process to release Wayland surfaces (atomic shutdown)
    timeout 2s bash -c "while pgrep -x 'qs' > /dev/null; do sleep 0.1; done"
    
    # If it's still hanging, force it
    pgrep -x "qs" >/dev/null && pkill -9 -x "qs"
    exit 0
fi

# --- STARTUP LOGIC ---

# 1. Scaling & Vibe Fixes for your 34" Ultrawide
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1
export QT_FONT_DPI=96

# 2. Performance & Memory (v4 Engine optimized)
export QSG_RENDER_LOOP=threaded
export QML_DISABLE_DISK_CACHE=0
export MALLOC_ARENA_MAX=1
export QT_QML_SINGLETON_REUSE=1

# 3. Notification Handoff
# We KILL Mako and STOP its service so it doesn't fight Noctalia for DBus control.
# Noctalia's built-in notification plugin will now handle all alerts.
pkill -9 mako 2>/dev/null
systemctl --user stop mako.service 2>/dev/null

# 4. Launch Noctalia via UWSM
# Wrapping in 'uwsm app' ensures it lives in its own systemd scope
uwsm app -- $NOCTALIA_BIN -c "$NOCTALIA_TARGET" &>/dev/null &

disown
exit 0
