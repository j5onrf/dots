<img width="3840" height="2160" alt="2026-08-18_14-33-28" src="https://github.com/user-attachments/assets/5ce36771-86f3-436b-85f3-ffc5157e8a6d" />

# C-Shell Precision — Left Rail Dock v0.1

Fast, autohide floating left rail dock for **Hyprland** in **Quickshell**.

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
├── c-shell.qml          # Main Quickshell UI file
├── cf-toggle.sh         # Launch & toggle script
└── 10-cf-reload.sh      # Theme change reload hook (Optional / Omarchy)
```

---

## 🚀 Installation & Setup

### 1. Place the Files
Clone the repository and place the files in your preferred directories (e.g., `~/.config/quickshell/` and `~/.local/bin/` or `~/.config/hypr/scripts/`).

### 2. Make Scripts Executable
Ensure the shell scripts have execute permissions:
```bash
chmod +x cf-toggle.sh 10-cf-reload.sh
```

### 3. Configure Target Paths
Open `cf-toggle.sh` and `10-cf-reload.sh` in your text editor and ensure the `TARGET` path points to the location where you saved `c-shell.qml`:

```bash
TARGET="$HOME/path/to/c-shell.qml"
```

---

## ⚙️ Hyprland Integration

Add the toggle script to your Hyprland configuration:

### Standard (`hyprland.conf`)
```ini
# Autostart on login
exec-once = /path/to/cf-toggle.sh

# Toggle keybind
bind = CTRL SHIFT, 3, exec, /path/to/cf-toggle.sh
```

### Lua Configuration (`hyprland.lua`)
```lua
hl.exec(os.getenv("HOME") .. "/path/to/cf-toggle.sh")
hl.bind("CTRL + SHIFT + 3", hl.dsp.exec_cmd(os.getenv("HOME") .. "/path/to/cf-toggle.sh"))
```

---

## 🎨 Theme Reload Hook (Optional)

If you use a theme switcher with hook support (such as Omarchy):

1. Place `10-cf-reload.sh` into your theme hook directory:
   ```bash
   cp 10-cf-reload.sh ~/.config/omarchy/hooks/theme-set.d/
   ```
2. Verify that the path to `c-shell.qml` inside `10-cf-reload.sh` matches your install directory.

---

## 📊 Memory Profiling

Standard tools like `btop` report full **RSS (~240MB)**, which double-counts shared Qt6, Wayland, and Mesa GPU driver mappings. 

Real memory breakdown:
* **Private Dirty (Unique RAM):** **~88 MB** (Actual physical RAM dedicated solely to `c-shell.qml`).
* **PSS (True System Cost):** **~122 MB** (Shared system libraries divided evenly across running processes).

### Check Real Memory Usage:
```bash
cat /proc/$(pgrep -f c-shell.qml)/smaps_rollup | grep -E "Rss|Pss|Private_Dirty"
```
