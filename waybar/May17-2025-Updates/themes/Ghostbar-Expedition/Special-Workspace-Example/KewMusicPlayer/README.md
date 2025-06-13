# KewMusicPlayer Scratchpad for Waybar

This guide helps you enable a "scratchpad" feature for KewMusicPlayer, allowing you to quickly launch and toggle its visibility. The KewMusicPlayer icon will appear in your Waybar when active.

## Prerequisites

1.  **KewMusicPlayer Installed:** Ensure KewMusicPlayer is installed and you can launch it (e.g., via `kew` command).
2.  **Kitty Terminal:** This setup uses `kitty --class "KewMusicPlayer" kew` to launch KewMusicPlayer and assign it a specific window class. Ensure Kitty is installed if you use this launch command.
3.  **Font Awesome (Pro/Free):** Your Waybar theme must have Font Awesome correctly installed and configured in your `style.css` for the icons to display. The icon used for KewMusicPlayer in this example is `\uf8c9` (a music player/equalizer icon).

## Setup Instructions

### 1. Hyprland Configuration

Add the following to your Hyprland user configuration file (e.g., `~/.config/hypr/custom.conf` for ML4W users, or your main `hyprland.conf`):

```conf
# --- KewMusicPlayer Scratchpad ---
workspace = special:music                                      # Define a new special workspace for music
windowrule = workspace special:music silent, class:^(KewMusicPlayer)$ # Rule to move KewMusicPlayer to it

# Optional: Make KewMusicPlayer float and set a default size.
windowrulev2 = float,class:^(KewMusicPlayer)$
windowrulev2 = size 800 1000,class:^(KewMusicPlayer)$ # Adjust size as preferred
# windowrulev2 = center,class:^(KewMusicPlayer)$ # Optional: Uncomment to explicitly center

# Keybinds for KewMusicPlayer Scratchpad
bind = $mainMod, m, exec, kitty --class "KewMusicPlayer" kew      # Launch KewMusicPlayer to scratchpad
bind = $mainMod ALT, N, togglespecialworkspace, music # Toggle 'special:music' visibility
```

**Note on Keybinds:**
*   `$mainMod, m`: Launches KewMusicPlayer. The `windowrule` will automatically send it to `special:music`.
*   `$mainMod ALT, N`: Toggles the visibility of the `special:music` workspace as an overlay.
*   Make sure these keybinds do not conflict with your existing Hyprland setup.

After adding these lines, reload Hyprland (e.g., `hyprctl reload` or `$mainMod + SHIFT + R`).

### 2. Waybar Configuration

Your Waybar configuration likely already handles the icon for KewMusicPlayer if you've previously set it up.

1.  **Check your Waybar configuration file** (e.g., `~/.config/waybar/conf/ghost-exp.jsonc` or `~/.config/waybar/modules.json`).
2.  **Ensure the `hyprland/workspaces#rw` module has:**
    *   `"show-special": true` (to display icons for special workspaces).
    *   The following rule (or similar) within its `"window-rewrite"` section:
        ```json
        "window-rewrite": {
            // ... other rules ...
            "class<KewMusicPlayer>": "<span line-height='1'>\uf8c9</span>", // Ensures KewMusicPlayer icon
            // ... other rules ...
        }
        ```
    If these are already in place, no Waybar configuration changes are needed for the icon.

3.  If you made changes (like setting `"show-special": true`), restart Waybar (e.g., `killall waybar && waybar &` or `$mainMod + SHIFT + W`).

---

After editing, restart Waybar (e.g., `killall waybar && waybar &` or `$mainMod + SHIFT + W`).

## Usage

*   **Launch KewMusicPlayer to Scratchpad:** Press `$mainMod + m`.
    *   KewMusicPlayer will launch inside a Kitty terminal with the class `KewMusicPlayer`.
    *   The `windowrule` will move it to the `special:music` workspace.
    *   The `\uf8c9` icon (or your chosen icon) should appear in Waybar.
*   **Toggle KewMusicPlayer Visibility:** Press `$mainMod + ALT + N`.
    *   KewMusicPlayer (and its `special:music` overlay) will appear or disappear.
*   **(Optional) Switch Fully to Music Scratchpad:** If you enabled a bind like `$mainMod + ALT + B`, use that to switch your entire view to the `special:music` workspace.

## Notes

*   **Icon:** The icon `\uf8c9` is a Font Awesome music player/equalizer style icon. Ensure it's available and correctly rendered by your Font Awesome setup.
*   **Class Name:** The `windowrule` and `window-rewrite` rely on the class `KewMusicPlayer`. This is set by `kitty --class "KewMusicPlayer" ...`. If you launch KewMusicPlayer differently, you might need to adjust the class name. Use `hyprctl clients` or `hyprctl activewindow` to find the correct class if it doesn't work.
*   **Waybar Icon Visibility:** As discussed previously, the Waybar icon's behavior when the scratchpad overlay is hidden (but the window still exists in the special workspace) depends on your Hyprland version's IPC reporting. The `window-rewrite` ensures the icon shows when KewMusicPlayer is present in that workspace.
*   **`$mainMod`:** Refers to your Super/Windows key (or whatever you have it set to in Hyprland).

---

This README provides a clear path for users to set up KewMusicPlayer in its own special workspace, leveraging the configuration you've already found works well.
