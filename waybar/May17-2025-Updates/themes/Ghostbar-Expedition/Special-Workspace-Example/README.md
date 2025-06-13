# KeePassXC Scratchpad for Waybar

This guide helps you enable a "scratchpad" feature for KeePassXC, allowing you to quickly launch and toggle its visibility. The KeePassXC icon will appear in your Waybar.

## Prerequisites

*   KeePassXC installed (at `/usr/bin/keepassxc`).
*   Font Awesome Pro correctly configured in your Waybar `style.css`.

## Setup Instructions

### 1. Hyprland Configuration

Add the following to your Hyprland user configuration file (e.g., `~/.config/hypr/custom.conf` for ML4W users):

```conf
# --- KeePassXC Scratchpad ---
workspace = special:scratchpad
windowrule = workspace special:scratchpad silent, class:^(org.keepassxc.KeePassXC)$
bind = $mainMod ALT, K, exec, /usr/bin/keepassxc      # Launch KeePassXC to scratchpad
bind = $mainMod ALT, S, togglespecialworkspace, scratchpad # Toggle scratchpad visibility
```

After adding, reload Hyprland (e.g., `hyprctl reload` or `$mainMod + SHIFT + R`).

### 2. Waybar Configuration

Modify your Waybar configuration file (e.g., `~/.config/waybar/conf/ghost-exp.jsonc`).
Locate the `hyprland/workspaces#rw` module and ensure the following:

```json
{
    // ... other modules ...
    "hyprland/workspaces#rw": {
        // ... your existing settings ...
        "show-special": true, // Enable this to see the scratchpad icon
        "window-rewrite": {
          "org.keepassxc.KeePassXC": "\uf084", // Icon for KeePassXC (key icon)
            // ... your other window-rewrite rules ...
        }
        // Ensure format-icons, persistent-workspaces, etc. are as you need them.
    },
    // ... other modules ...
}
```

After editing, restart Waybar (e.g., `killall waybar && waybar &` or `$mainMod + SHIFT + W`).

## Usage

*   **Launch KeePassXC to Scratchpad:** `$mainMod + ALT + K`
*   **Toggle Scratchpad Visibility:** `$mainMod + ALT + S`

## Notes

*   The icon (`\uf084`) is a Font Awesome "key" icon. Ensure it's available in your Font Awesome Pro Duotone setup.
*   The Waybar icon's behavior when the scratchpad is hidden depends on your Hyprland version's IPC. The `window-rewrite` ensures the icon shows when KeePassXC is in the scratchpad.
*   `$mainMod` refers to your Super/Windows key (or whatever you have it set to in Hyprland).

---

This README is concise and gives users the essential steps. You can add more details to the "Notes" or create a separate "Troubleshooting" section if common issues arise.
