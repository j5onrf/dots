# Dynamic Hyprshade Module for Waybar

This project provides a solution for a common Waybar challenge: creating a custom module with a **dynamic icon that changes state on-click**, without resorting to an inefficient polling `interval`.

This module controls [Hyprshade](https://github.com/loqusion/hyprshade) with a left-click to toggle the shader and a right-click to select a new one via Rofi. The icons used are from the **Font Awesome 6 Pro** collection. The entire system is powered by a single, persistent Python daemon that sleeps and waits for signals, ensuring **zero CPU usage** when idle.

### 🎥 Demo

![FullScreen-2025-06-08_21-32-14](https://github.com/j5onrf/dots/blob/main/waybar/May17-2025-Updates/themes/Ghost-Modern-Matugen/Hyprshade-Script/python-solution/Full-Setup/FullScreen-2025-06-09_18-06-12.png)

![FullScreen-2025-06-08_21-32-14](https://github.com/user-attachments/assets/384aa71a-586b-45c5-893a-94218e6f92e8)

---

## ✨ Features

*   **Truly On-Demand:** Event-driven and consumes no resources while idle.
*   **Dynamic Icon:** Instantly reflects the on/off state of Hyprshade.
*   **Smart Toggle:** Left-clicking toggles the last shader you selected from the Rofi menu.
*   **Rofi Integration:** Right-clicking opens a Rofi menu to select and immediately apply a new shader.
*   **Self-Contained:** All logic is contained within a single, easy-to-update Python script.
*   **Minimalist & Efficient:** Perfect for users who value system performance.

---

## 📋 Prerequisites & Core Dependencies

### Required Software
*   [Waybar](https://github.com/Alexays/Waybar)
*   [Hyprland](https://hyprland.org/)
*   [hyprshade](https://github.com/loqusion/hyprshade)
*   [Rofi](https://github.com/davatorium/rofi)
*   **Python 3**

### ⚠️ Foundational Requirement: ml4w Dotfiles

Please note: This Waybar configuration is designed to integrate seamlessly with the **[ml4w dotfiles](https://github.com/ml4w/dotfiles)** ecosystem.

For this module to work as intended **out-of-the-box**, it requires that foundation to be in place, as it relies on specific scripts and configuration paths provided by that project.

---

## 🔧 Porting to a Non-ml4w Setup

If you wish to use this module **independently** of the ml4w dotfiles, you must adapt the following paths inside the `hyprshade_daemon.py` script to match your own environment.

1.  **Settings File (`SETTINGS_FILE`):** This file stores the name of the shader you choose from Rofi.
    *   **ml4w Path:** `~/.config/ml4w/settings/hyprshade.sh`
    *   **To Adapt:** Change this variable in the script to a path you control. For example:
        ```python
        SETTINGS_FILE = os.path.expanduser("~/.config/hypr/my_hyprshade_settings.sh")
        ```

2.  **Rofi Theme (`rofi_cmd`):** This points to the Rofi theme for the shader menu.
    *   **ml4w Path:** `~/.config/rofi/config-hyprshade.rasi`
    *   **To Adapt:** Change the path to your own Rofi theme. If you want to use your default Rofi config, simply **delete** the entire `-config` line from the `rofi_cmd` list in the script.

---

## ⚙️ Installation

### 1. The Control Script

*   **Create the file:**
    ```bash
    touch ~/.config/hypr/scripts/hyprshade_daemon.py
    ```

*   **Make it executable:**
    ```bash
    chmod +x ~/.config/hypr/scripts/hyprshade_daemon.py
    ```

*   **Paste the following code into the file:**

    ```python
    #!/usr/bin/python3

    import os
    import signal
    import subprocess

    # --- CONFIGURATION ---
    STATE_FILE = "/tmp/hyprshade.state"
    SETTINGS_FILE = os.path.expanduser("~/.config/ml4w/settings/hyprshade.sh")
    FALLBACK_SHADER = "blue-light-filter-75"
    ICON_ON = "\ue019"
    ICON_OFF = "\ue018"

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

    print_status()

    while True:
        try:
            signal.pause()
        except InterruptedError:
            pass
    ```

### 2. The Waybar Configuration

Add the following JSON object to your Waybar `config` file.

```json
"custom/hyprshade": {
  "exec": "~/.config/hypr/scripts/hyprshade_daemon.py",
  "persistent": true,
  "return-type": "json",
  "tooltip": false,
  "on-click": "pkill -SIGUSR1 -f hyprshade_daemon.py",
  "on-click-right": "pkill -SIGUSR2 -f hyprshade_daemon.py"
}
```

### 3. Reload Waybar

Finally, reload Waybar for the changes to take effect (`hyprctl reload` or restart the Waybar process).

---

## 🧠 How It Works

This module uses a persistent Python script as a mini-daemon.
*   **`"persistent": true`**: Tells Waybar to launch the script once and keep it running.
*   **`signal.pause()`**: The Python script spends all its time in a sleep state, consuming no CPU.
*   **`on-click`**: Clicking uses `pkill` to send a Linux signal (`SIGUSR1` or `SIGUSR2`) to the already running daemon.
*   **Signal Handlers**: The daemon wakes up instantly, runs the appropriate function, prints the updated JSON for Waybar, and immediately goes back to sleep. This event-driven architecture is far more efficient than polling with an `interval`.

---

## 📜 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it as you see fit.
