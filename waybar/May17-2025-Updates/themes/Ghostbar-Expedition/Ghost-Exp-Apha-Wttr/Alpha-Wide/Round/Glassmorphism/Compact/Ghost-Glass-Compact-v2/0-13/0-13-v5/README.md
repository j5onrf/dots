>
[**Ghost-Glass Compact (v0.13-v5)**](/waybar/May17-2025-Updates/themes/Ghostbar-Expedition/Ghost-Exp-Apha-Wttr/Alpha-Wide/Round/Glassmorphism/Compact/Ghost-Glass-Compact-v2/0-13/0-13-v5)
*Optimized for ML4W v2.12.1*

![dank](https://github.com/user-attachments/assets/ebb8990e-e08d-4ec1-a40b-1e674cd256ea)

>
>
>
>
`keybindings.conf`
```bash

# --- Terminals
bind = $mainMod, S, exec, kitty
bind = $mainMod ALT, S, exec, kitty --title floating_kitty
bind = $mainMod, A, exec, alacritty
bind = $mainMod, Z, exec, ghostty

# Shell & Bar Toggles
bind = $mainMod, X, exec, ~/.config/waybar/toggle.sh
bind = $mainMod, C, exec, ~/.config/quickshell/caelestia/toggle.sh
bind = $mainMod, V, exec, ~/.config/noctalia/toggle.sh

# Open ML4W Settings TUI with Super + Ctrl + S
bind = $mainMod CTRL, S, exec, kitty --class ml4w-tui -e ml4w-dotfiles-settings com.ml4w.dotfiles

# Swaps the current window with the one to its right in the strip
bind = $mainMod SHIFT, S, layoutmsg, swapcol r

# One-handed navigation (WASD) using Shift
bind = $mainMod SHIFT, A, movefocus, l
bind = $mainMod SHIFT, D, movefocus, r

# Smoothly resize with Super + Alt + a-d
binde = $mainMod CTRL, a,  resizeactive, -40 0
binde = $mainMod CTRL, d, resizeactive, 40 0

# Bind Alt + Comma to reset the Master layout columns to 50%
bind = ALT, comma, exec, hyprctl dispatch layoutmsg colresize all 0.5

# --- Screenshots
bind = , Print, exec, ~/.config/hypr/scripts/fast_screenshot.sh
bind = SHIFT, Print, exec, ~/.config/hypr/scripts/fast_screenshot_full.sh
bind = CTRL, Print, exec, grimblast --freeze copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png

```
>
>
>
>
`~/.config/zshrc/25-aliases`
```bash

## --- System & UI ---
alias c='clear'
alias ff='fastfetch'
alias hr='hyprctl reload'
alias hc='hyprctl clients'

## --- Package Management ---
alias p='paru'
alias x='paru -Syu'                        # Full upgrade
alias pr='paru -Rns'                       # Remove + Configs + Unneeded deps
alias xclean='paru -Rns $(paru -Qtdq)'     # Orphan sweep
alias um='sudo reflector --country "United States" --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist'

## --- Scripts & Toggles ---
alias uk='sudo ~/.config/scripts/kernel-update-toggle.sh'

```

>
>
>
>
`Windowrules`
```bash

# --- Floating Rules (New Syntax) ---

# File Pickers (GTK and KDE)
windowrule = float on, match:class ^(xdg-desktop-portal-gtk)$
windowrule = size 800 500, match:class ^(xdg-desktop-portal-gtk)$
windowrule = center on, match:class ^(xdg-desktop-portal-gtk)$

windowrule = float on, match:class ^(org.gnome.FileRoller)$
windowrule = size 800 500, match:class ^(org.gnome.FileRoller)$
windowrule = center on, match:class ^(org.gnome.FileRoller)$

# --- Specific Title Matches ---
# For browsers or apps that don't use the standard portal class
windowrule = float on, match:title ^(Open File)$
windowrule = float on, match:title ^(Save As)$
windowrule = float on, match:title ^(File Upload)$

# --- Kitty Float ---
windowrule = match:title ^(floating_kitty)$, float on
windowrule = match:title ^(floating_kitty)$, center on
windowrule = match:title ^(floating_kitty)$, size 800 500

```


>
>
>
>
`Animations`
```bash

animations {
    enabled = yes
    bezier = quick, 0.05, 0.9, 0.1, 1.05
    bezier = direct, 0.2, 1, 0.3, 1
    animation = global, 1, 2.5, direct
    animation = windows, 1, 2, quick, popin 95%
    animation = windowsIn, 1, 2, quick, popin 95%
    animation = windowsOut, 1, 1.5, direct, popin 95%
    animation = workspaces, 1, 2, direct, fade
    animation = layers, 1, 2, quick, fade
    animation = layersIn, 1, 2, quick, fade
    animation = layersOut, 1, 1.5, direct, fade
    animation = fadeIn, 1, 1.5, direct
    animation = fadeOut, 1, 1.5, direct
    animation = border, 1, 1, direct
}

```

>
>
>
>
`Layouts.conf`
```bash

# Horizontal scrolling behavior (Niri-style). By setting the column_width to 0.5,
# -every window defaults to exactly half, creating a perfect, consistent split.

general {
    layout = scrolling
}

scrolling {
    column_width = 0.5
    focus_fit_method = 1
}

```

>
>
>
>
`Monitors`
```bash

## Toggle between Android-style (2x) and High-Density (1x)
bind = ALT, R, exec, ~/.config/hypr/conf/scripts/toggle_scale.sh

monitor=, 3440x1440@120, auto, 2

```


