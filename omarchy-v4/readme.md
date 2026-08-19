<img width="3840" height="2160" alt="2026-08-18_14-33-28" src="https://github.com/user-attachments/assets/5ce36771-86f3-436b-85f3-ffc5157e8a6d" />

# C-Shell Precision — Left Rail Dock v0.9

Fast, autohide floating left rail dock for **Hyprland** & **Omarchy** written in **Quickshell**.

---

## 🌟 Features

* **Zero-Gap Left Dock:** 30px compact width flush to the screen edge.
* **Smart Workspaces (1–10):** 1–5 persistent; 6–10 appear only when active/occupied.
* **Theme-Proof Opacity:** 100% bright active/occupied text; 35% faded empty slots.
* **Accordion Tools Drawer:** CPU monitor, clipboard, night light, autohide lock.
* **Persistent Autohide:** State saves to disk; survives reboots and theme changes.
* **Compact Clock:** Zero-gap 2-row time; click for seconds, right-click for calendar.
* **Power & Volume Combo:** Left-click power menu, right-click mute, wheel volume, middle-click high-contrast text toggle.
* **Live Theme Sync:** Syncs accent colors from `colors.toml` while maintaining dark surfaces.

---

## 📁 Repository Structure

```text
├── c-shell.qml      # Main Quickshell UI file
├── cf-toggle.sh     # Dock launch / toggle script
└── cf-reload.sh     # Theme-change reload hook script
```

---

## 🚀 Installation & Setup

### 1. Clone & Place Files
Clone the repository and place the files in your preferred directories (e.g. keeping `c-shell.qml` in `~/.config/quickshell/` and the scripts in `~/.config/hypr/scripts/` or `~/.local/bin/`).

### 2. Make Scripts Executable
```bash
chmod +x cf-toggle.sh cf-reload.sh
```

### 3. Verify Target Paths
Open `cf-toggle.sh` and `cf-reload.sh` in your text editor and ensure the `TARGET` variable points to the location of your `c-shell.qml` file:

```bash
TARGET="$HOME/.config/quickshell/c-shell.qml"
```

---

## ⚙️ Hyprland Integration

Add the toggle script to your Hyprland configuration to enable autostart and keybind toggling.

### Standard (`hyprland.conf`)
```ini
# Autostart dock on login
exec-once = /path/to/cf-toggle.sh

# Toggle keybind (e.g. Ctrl + Shift + 3)
bind = CTRL SHIFT, 3, exec, /path/to/cf-toggle.sh
```

### Lua Configuration (`hyprland.lua`)
```lua
local home = os.getenv("HOME")

-- Autostart dock on login
hl.exec(home .. "/path/to/cf-toggle.sh")

-- Toggle keybind (e.g. Ctrl + Shift + 3)
hl.bind("CTRL + SHIFT + 3", hl.dsp.exec_cmd(home .. "/path/to/cf-toggle.sh"))
```

---

## 🎨 Theme Reload Hook (Omarchy)

If you use Omarchy (or another theme switcher with hook support), symlink `cf-reload.sh` into your `theme-set.d` hook folder so the dock automatically updates its accent colors on theme changes:

```bash
# 1. Create the hook directory if it doesn't exist
mkdir -p ~/.config/omarchy/hooks/theme-set.d

# 2. Symlink cf-reload.sh (prefixed with 10- for execution order)
ln -sf /path/to/cf-reload.sh ~/.config/omarchy/hooks/theme-set.d/10-cf-reload.sh
```

---

## 📊 Memory Profiling

Standard system monitors (like `btop`) report full **RSS (~240MB)**, which double-counts shared Qt6, Wayland, and Mesa GPU driver mappings.

Real memory breakdown:
* **Private Dirty (Unique RAM):** **~88 MB** (Actual physical RAM dedicated solely to `c-shell.qml`).
* **PSS (True System Cost):** **~122 MB** (Shared system libraries divided evenly across running processes).

### Check Real Memory Usage:
```bash
cat /proc/$(pgrep -f c-shell.qml)/smaps_rollup | grep -E "Rss|Pss|Private_Dirty"
```
