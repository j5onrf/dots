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

```
>
>
>
>
`~/.config/zshrc/25-aliases`
```bash

## System & Navigation
alias c='clear'
alias ff='fastfetch'

## Package Management
alias p='paru'
alias pr='paru -Rns'
alias x='paru -Syu'
alias um="sudo reflector --verbose --country 'United States' --protocol https --age 12 --latest 30 --sort rate --download-timeout 5 --number 10 --save /etc/pacman.d/mirrorlist"

## Desktop & Window Manager
alias hr='hyprctl reload'
alias hrr='hyprctl dispatch layoutmsg colresize all 0.5'
alias hc='hyprctl clients'
alias uk='sudo ~/.config/scripts/kernel-update-toggle.sh'

```

>
>
>
>
`Windowrules`
```bash

# --- Kitty Float ---
windowrule = match:title ^(floating_kitty)$, float on
windowrule = match:title ^(floating_kitty)$, center on
windowrule = match:title ^(floating_kitty)$, size 800 500

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

```


>
>
>
>
`Animations`
```bash

animations {
    enabled = yes

    # Ultra-fast curves for igpu
    bezier = quick, 0.15, 0, 0.1, 1
    bezier = direct, 0.23, 1, 0.32, 1

    # Global speed: 3-4 is the "sweet spot" for igpu
    animation = global, 1, 3, direct
    
    # The 'Niri' Scroll: MUST be enabled for the scrolling layout
    # Use 'slide' to see the windows move across the 'tape'
    animation = workspaces, 1, 4, direct, slide
    
    # Fast window spawns
    animation = windows, 1, 3, quick, popin 90%
    animation = windowsOut, 1, 2, quick, popin 90%
    
    # Fades: Keep these very fast (under 200ms) to avoid 'ghosting'
    animation = fadeIn, 1, 2, quick
    animation = fadeOut, 1, 2, quick
}

```

>
>
>
>
`Layouts.conf`
```bash

# Horizontal scrolling behavior (Niri-style). By setting the column_width to 0.5, every window
# defaults to exactly half, creating a perfect, consistent split.

general {
    layout = scrolling
}

scrolling {
    column_width = 0.5
    focus_fit_method = 1
}

```
