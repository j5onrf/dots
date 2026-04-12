>
[**Ghost-Glass Compact (v0.13-v5)**](/waybar/May17-2025-Updates/themes/Ghostbar-Expedition/Ghost-Exp-Apha-Wttr/Alpha-Wide/Round/Glassmorphism/Compact/Ghost-Glass-Compact-v2/0-13/0-13-v5)
*Optimized for ML4W v2.12.1*

<img width="3440" height="1440" alt="FullScreen-2026-03-31_20-48-26" src="https://github.com/user-attachments/assets/ebb8990e-e08d-4ec1-a40b-1e674cd256ea" />

>
>
>
>
`keybindings.conf`
```bash

# --- Terminals
bind = $mainMod, S, exec, kitty
bind = $mainMod, A, exec, alacritty
bind = $mainMod, Z, exec, ghostty

# Move KeePassXC to a special workspace named 'keepass' silently
windowrule = workspace special:keepassxc, match:class ^(org.keepassxc.KeePassXC)$

# Shell & Bar Toggles
bind = $mainMod, X, exec, ~/.config/waybar/toggle.sh
bind = $mainMod, C, exec, ~/.config/quickshell/caelestia/toggle.sh
bind = $mainMod, V, exec, ~/.config/noctalia/toggle.sh

# Open ML4W Settings TUI with Super + Ctrl + S
bind = $mainMod CTRL, S, exec, kitty --class ml4w-tui -e ml4w-dotfiles-settings com.ml4w.dotfiles

# --- Swapsplit
bind = $mainMod SHIFT, S, layoutmsg, swapsplit

# --- Screenshots
bind = , Print, exec, ~/.config/hypr/scripts/fast_screenshot.sh
bind = SHIFT, Print, exec, ~/.config/hypr/scripts/fast_screenshot_full.sh
bind = CTRL, Print, exec, grimblast --freeze copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
