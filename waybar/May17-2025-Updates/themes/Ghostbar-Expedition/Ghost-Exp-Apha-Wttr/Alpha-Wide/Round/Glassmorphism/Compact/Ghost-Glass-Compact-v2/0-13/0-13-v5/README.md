> ## 💎 Current Version
[**Ghost-Glass Compact (v0.13-v5)**](/waybar/May17-2025-Updates/themes/Ghostbar-Expedition/Ghost-Exp-Apha-Wttr/Alpha-Wide/Round/Glassmorphism/Compact/Ghost-Glass-Compact-v2/0-13/0-13-v5)
*Optimized for ML4W v2.12.1*

<img width="3440" height="1440" alt="FullScreen-2026-03-31_20-48-26" src="https://github.com/user-attachments/assets/ebb8990e-e08d-4ec1-a40b-1e674cd256ea" />

## ⌨️ Keybindings

Add the following to your `custom.conf`

```bash
# ----------------------------------
# Keybindings (j5onrf Dots)
# ----------------------------------

# --- Terminals
bind = $mainMod, S, exec, kitty
bind = $mainMod, A, exec, alacritty
bind = $mainMod, Z, exec, ghostty

# --- Rofi Launcher
bind = $mainMod, R, exec, zsh "$HOME/.config/rofi/bin/launcher"

# --- UI Toggles (Waybar & Caelestia)
bind = $mainMod, C, exec, ~/.config/waybar/toggle.sh
bind = $mainMod, X, exec, ~/.config/caelestia/toggle.sh
bind = $mainMod, D, exec, caelestia shell drawers toggle dashboard

# --- Utilities
bind = $mainMod, H, exec, ~/.config/hypr/scripts/hyprsunset.sh toggle

# Open ML4W Settings TUI with Super + Ctrl + S
bind = $mainMod CTRL, S, exec, kitty --class ml4w-tui -e ml4w-dotfiles-settings com.ml4w.dotfiles

# --- Screenshots
bind = , Print, exec, ~/.config/hypr/scripts/fast_screenshot.sh
bind = SHIFT, Print, exec, ~/.config/hypr/scripts/fast_screenshot_full.sh
bind = $mainMod ALT, P, exec, grimblast --freeze copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
