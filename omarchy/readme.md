# ⚡ Veo | Vertical Omarchy
`Omarchy v3.6.0`

<img alt="20260423_182531" src="https://github.com/user-attachments/assets/f6b4f758-96b1-4442-b4ec-74b376402b99" />

`bindings.conf`
```bash
wip

# --- Core System ---
bind = SUPER, Q, killactive

# --- Applications ---
bind = SUPER, S, exec, uwsm app -- kitty
bind = SUPER, A, exec, uwsm app -- alacritty
bind = SUPER, R, exec, uwsm app -- omarchy-menu
bind = SUPER ALT, S, exec, uwsm app -- kitty --title floating_kitty
bind = SUPER SHIFT, F, exec, uwsm app -- nautilus --new-window
bind = SUPER, G, exec, hyprctl clients | grep -q "class: brave-origin-beta" && hyprctl dispatch focuswindow class:brave-origin-beta || uwsm app -- brave-origin-beta
bind = SUPER, F, exec, hyprctl clients | grep -q "class: org.gnome.Nautilus" && hyprctl dispatch focuswindow class:org.gnome.Nautilus || uwsm app -- nautilus --new-window

# Window Switcher using the custom selector script
bind = SUPER, Tab, exec, uwsm app -- kitty -o font_size=16 --title floating_kitty -e $HOME/.config/hypr/Scripts/window-selector.sh

# --- Utilities & Clipboard ---
bind = ALT, C, exec, uwsm app -- walker -m clipboard
bind = ALT, X, exec, /usr/local/bin/qs -c noctalia ipc call launcher clipboard
bind = ALT, R, exec, ~/.config/hypr/Scripts/toggle_scale.sh
bind = SUPER, H, exec, omarchy-toggle-nightlight
bind = SUPER, P, exec, ~/.config/hypr/Scripts/power-toggle
bind = , F1, exec, uwsm app -- keepassxc

# --- Shell & UI Toggles (Physical Switchboard) ---
bind = , XF86Tools,   exec, ~/.config/hypr/Scripts/w-toggle.sh      # G1: Waybar / Omarchy
bind = , XF86Launch5, exec, ~/.config/hypr/Scripts/veo-toggle.sh    # G2: Veo UI
bind = , XF86Launch6, exec, ~/.config/hypr/Scripts/f-toggle.sh      # G3: Shell-Fusion
bind = , XF86Launch7, exec, ~/.config/hypr/Scripts/c-toggle.sh      # G4: Caelestia
bind = , XF86Launch8, exec, ~/.config/hypr/Scripts/n-toggle.sh      # G5: Noctalia
bind = , XF86Launch9, exec, ~/.config/hypr/Scripts/d-toggle.sh      # G6: DankMaterialShell

# --- Navigation & Scrolling Layout ---
bind = SUPER SHIFT, A, movefocus, l
bind = SUPER SHIFT, D, movefocus, r
bind = SUPER SHIFT, S, layoutmsg, swapcol r
# bind = ALT, comma, exec, hyprctl dispatch layoutmsg colresize all 0.5
bind = SUPER, Tab, exec, kitty -o font_size=16 --title floating_kitty -e $HOME/.config/hypr/Scripts/window-selector.sh

# --- Resizing (WASD) ---
binde = SUPER CTRL, W, resizeactive, 0 -100
binde = SUPER CTRL, A, resizeactive, -100 0
binde = SUPER CTRL, S, resizeactive, 0 100
binde = SUPER CTRL, D, resizeactive, 100 0
binde = SUPER ALT, W, moveactive, 0 -100
binde = SUPER ALT, Z, moveactive, 0 100
binde = SUPER ALT, A, moveactive, -100 0
binde = SUPER ALT, D, moveactive, 100 0

# --- Screenshots ---
# env = XDG_SCREENSHOTS_DIR,$HOME/Pictures/Screenshots
bind = , Print, exec, pkill slurp; grimblast --notify copysave area
bind = SHIFT, Print, exec, grimblast --notify copysave screen
bind = CTRL, Print, exec, pkill slurp; grimblast --notify --freeze copysave area
bind = SUPER, Print, exec, hyprctl clients | grep -q "class: org.gnome.Nautilus" && hyprctl dispatch focuswindow class:org.gnome.Nautilus || uwsm app -- nautilus $XDG_SCREENSHOTS_DIR

# --- Workspace Management ---
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = 3, persistent:true
workspace = 4, persistent:true
workspace = 5, persistent:true

# Switch Workspaces (1-10)
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

# Move Window to Workspace (1-10)
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

# --- Window Rules ---
windowrule = match:title ^(floating_kitty)$, float on
windowrule = match:title ^(floating_kitty)$, center on
windowrule = match:title ^(floating_kitty)$, size 875 600
windowrule = float on, match:class ^(xdg-desktop-portal-gtk)$
windowrule = size 875 600, match:class ^(xdg-desktop-portal-gtk)$
windowrule = center on, match:class ^(xdg-desktop-portal-gtk)$
windowrule = float on, match:title ^(Open File)$
windowrule = float on, match:title ^(Save As)$
windowrule = float on, match:title ^(File Upload)$
```


`looknfeel.conf `
```bash
wip

# --- Personal Look'n'Feel ---

general {
    gaps_in = 0
    gaps_out = 0
    border_size = 0
    layout = scrolling
}

decoration {
    active_opacity = 1
    inactive_opacity = 1
    fullscreen_opacity = 1

    blur {
        enabled = false
    }

    shadow {
        enabled = false
    }
}

animations {
    enabled = true
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

scrolling {
    column_width = 0.5
    focus_fit_method = 1
}
```

`.bashrc`
```bash
wip

## --- System & UI ---
alias c='clear'
alias ff='fastfetch'
alias hr='hyprctl reload'
alias hc='hyprctl clients'
alias no='yay -S --noconfirm --provides=false'

## --- Backups ---
# Lightweight Config Sync
alias bc='mountpoint -q /run/media/j5/SSD_BACKUPS || udisksctl mount -b /dev/sda1; ~/.config/hypr/Scripts/config-backup.sh'

## --- Package Management ---
alias y='yay'
alias x='yay -Syu'
alias xx='sudo yay -Syu --hookdir /dev/null'
alias yr='yay -Rns'
alias xclean='bash ~/.config/hypr/Scripts/check-orphans.sh'
alias um='sudo reflector --country "United States" --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy'
alias uk='sudo /home/j5/.config/hypr/Scripts/kernel-update-toggle.sh'

# Basic Management
alias sl='sudo snapper list'

```
