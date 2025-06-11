#!/usr/bin/python3

import os
import signal
import subprocess

# --- CONFIGURATION ---
STATE_FILE = "/tmp/hyprshade.state"
SETTINGS_FILE = os.path.expanduser("~/.config/ml4w/settings/hyprshade.sh")
FALLBACK_SHADER = "blue-light-filter-75"
# ICON_ON = "\ue019"  # light-switch
# ICON_OFF = "\ue018" # light-switch
ICON_ON = "\uf673"    # light-bulb
ICON_OFF = "\uf0eb"   # light-bulb

# --- FUNCTIONS ---

def get_chosen_shader():
    """Reads the settings file to find the user's last Rofi choice."""
    try:
        with open(SETTINGS_FILE, 'r') as f:
            return f.read().split('"')[1]
    except (FileNotFoundError, IndexError):
        return FALLBACK_SHADER

def print_status():
    """Checks the state and prints the correct JSON to Waybar."""
    if os.path.exists(STATE_FILE):
        print(f'{{"text": "{ICON_ON}"}}', flush=True)
    else:
        print(f'{{"text": "{ICON_OFF}"}}', flush=True)

def toggle_action(signum, frame):
    """Handles the left-click (SIGUSR1). Toggles the current shader."""
    if os.path.exists(STATE_FILE):
        subprocess.run(["hyprshade", "off"])
        os.remove(STATE_FILE)
    else:
        shader = get_chosen_shader()
        if shader == "off":
            shader = FALLBACK_SHADER
        subprocess.run(["hyprshade", "on", shader])
        open(STATE_FILE, 'a').close()
    print_status()

def rofi_action(signum, frame):
    """Handles the right-click (SIGUSR2). Opens Rofi and applies the choice."""
    try:
        shader_list = subprocess.check_output(["hyprshade", "ls"]).decode('utf-8').strip()
        options = f"{shader_list}\noff"

        rofi_cmd = [
            "rofi", "-dmenu", "-replace",
            "-config", os.path.expanduser("~/.config/rofi/config-hyprshade.rasi"),
            "-i", "-no-show-icons", "-l", "4", "-width", "30", "-p", "Hyprshade"
        ]
        choice = subprocess.check_output(rofi_cmd, input=options, text=True).strip()

        if choice:
            with open(SETTINGS_FILE, 'w') as f:
                f.write(f'hyprshade_filter="{choice}"')
            
            if choice == "off":
                if os.path.exists(STATE_FILE): os.remove(STATE_FILE)
                subprocess.run(["hyprshade", "off"])
            else:
                if not os.path.exists(STATE_FILE): open(STATE_FILE, 'a').close()
                subprocess.run(["hyprshade", "on", choice])
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    print_status()

# --- MAIN EXECUTION ---
signal.signal(signal.SIGUSR1, toggle_action)
signal.signal(signal.SIGUSR2, rofi_action)

# Initial print on startup
print_status()

# Infinite sleep loop - waits for either signal, uses no CPU
while True:
    try:
        signal.pause()
    except InterruptedError:
        pass