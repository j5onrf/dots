# ⚡ Veo | Vertical Omarchy
`Omarchy v3.6.0`

<img alt="20260423_182531" src="https://github.com/user-attachments/assets/f6b4f758-96b1-4442-b4ec-74b376402b99" />

`bindings.conf`
```bash
wip

# --- Core System ---
bind = SUPER, Q, killactive

# --- Applications ---
bind = SUPER, S, exec, kitty
bind = SUPER, A, exec, alacritty
bind = SUPER, R, exec, omarchy-menu
bind = SUPER ALT, S, exec, kitty --title floating_kitty
bind = SUPER SHIFT, F, exec, uwsm-app -- nautilus --new-window
bind = SUPER, G, exec, hyprctl clients | grep -q "class: brave-origin-beta" && hyprctl dispatch focuswindow class:brave-origin-beta || uwsm app -- brave-origin-beta
bind = SUPER, F, exec, hyprctl clients | grep -q "class: org.gnome.Nautilus" && hyprctl dispatch focuswindow class:org.gnome.Nautilus || uwsm app -- nautilus --new-window

# --- Utilities & Clipboard ---
bind = ALT, C, exec, walker -m clipboard
bind = ALT, X, exec, /usr/local/bin/qs -c noctalia ipc call launcher clipboard
bind = ALT, R, exec, ~/.config/hypr/scripts/toggle_scale.sh
bind = , F2, exec, omarchy-toggle-nightlight
bind = , F3, exec, ~/.config/hypr/scripts/power-toggle
bind = , F1, exec, keepassxc

# --- Shell & UI Toggles (Physical Switchboard) ---
bind = , XF86Tools,   exec, ~/.config/hypr/scripts/w-toggle.sh      # G1: Waybar / Omarchy
bind = , XF86Launch5, exec, ~/.config/hypr/scripts/veo-toggle.sh    # G2: Veo UI
bind = , XF86Launch6, exec, ~/.config/hypr/scripts/f-toggle.sh      # G3: Shell-Fusion
bind = , XF86Launch7, exec, ~/.config/hypr/scripts/c-toggle.sh      # G4: Caelestia
bind = , XF86Launch8, exec, ~/.config/hypr/scripts/n-toggle.sh      # G5: Noctalia
bind = , XF86Launch9, exec, ~/.config/hypr/scripts/d-toggle.sh      # G6: DankMaterialShell

# Launch Walker in dmenu mode to switch between active windows
bind = , F4, exec, ~/.config/hypr/scripts/walker-windows.sh

# Launch Walker in dmenu mode to switch UI / Shells / Status Bars
bind = , F5, exec, ~/.config/hypr/scripts/walker-switchboard.sh

# --- Navigation & Scrolling Layout ---
bind = CTRL, Left,  movefocus, l
bind = CTRL, Right, movefocus, r
bind = SHIFT, Left,  swapwindow, l
bind = SHIFT, Right, swapwindow, r

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
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.4, 0, 0.2, 1
    bezier = snap, 0.34, 1.56, 0.64, 1
    animation = windowsIn, 1, 3, smoothIn, popin 80%
    animation = windowsOut, 1, 3, smoothIn, popin 80%
    animation = windowsMove, 1, 3, smoothIn, slide
    animation = border, 1, 5, default
    animation = workspaces, 1, 4, smoothIn, slide
    animation = layersIn, 1, 2, smoothIn, fade
    animation = layersOut, 1, 2, smoothIn, fade
}

scrolling {
    column_width = 0.50
    focus_fit_method = 0
}
```

`.bashrc`
```bash
wip

## --- System & UI ---
alias c='clear'
alias ff='fastfetch'
alias hc='hyprctl clients'
alias no='yay -S --noconfirm --provides=false'

## --- Backups ---
# Lightweight Config Sync
alias bc='mountpoint -q /run/media/j5/SSD_BACKUPS || udisksctl mount -b /dev/sda1; ~/.config/hypr/scripts/config-backup.sh'

## --- Package Management ---
alias y='yay'
alias x='yay -Syu'
alias yr='yay -Rns'
alias xclean='bash ~/.config/hypr/scripts/check-orphans.sh'
alias um='sudo reflector --country "United States" --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy'
alias uk='sudo ~/.config/hypr/scripts/kernel-update-toggle.sh'

## --- Snapper Management ---
alias ss='~/.config/hypr/scripts/snap.sh'
alias sl='sudo snapper list'
alias sd='sudo snapper delete'
