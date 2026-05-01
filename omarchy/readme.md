# ⚡ Veo | Vertical Omarchy
`Omarchy v3.6.0`

<img alt="20260423_182531" src="https://github.com/user-attachments/assets/f6b4f758-96b1-4442-b4ec-74b376402b99" />

`bindings.conf`
```bash
wip

# -----------------------------------------------------
# HYPRLAND BINDINGS - ACTIVE CONFIG (V4.9.2)
# -----------------------------------------------------

# --- 1. Core System ---
bind = SUPER, Q, killactive

# --- 2. Applications ---
bind = SUPER,       S, exec, kitty
bind = SUPER,       A, exec, alacritty
bind = SUPER,       R, exec, omarchy-menu
bind = SUPER ALT,   S, exec, kitty --title floating_kitty

# --- 2. Applications (Smart Launchers) ---
bind = ALT, Space, exec, ~/.config/hypr/scripts/smart-launch.sh brave-origin-beta
bind = SHIFT, Space, exec, ~/.config/hypr/scripts/smart-launch.sh brave-origin-beta --incognito
bind = CTRL, Space, exec, ~/.config/hypr/scripts/smart-launch.sh org.gnome.Nautilus "nautilus --new-window"
bind = SUPER, Z, exec, ~/.config/hypr/scripts/smart-launch.sh zeditor

bind = SUPER SHIFT, F, exec, uwsm app -- nautilus --new-window
# bind = SUPER SHIFT, B, exec, uwsm app -- brave-origin-beta --new-window
bind = SHIFT, Space, exec, uwsm app -- brave-origin-beta --incognito

# --- 3. Utilities & Clipboard ---
bind = ALT, C, exec, walker -m clipboard
bind = ALT, X, exec, /usr/local/bin/qs -c noctalia ipc call launcher clipboard
bind = ALT, R, exec, ~/.config/hypr/scripts/toggle_scale.sh
bind = ,     F2, exec, omarchy-toggle-nightlight
bind = ,     F3, exec, ~/.config/hypr/scripts/power-toggle
bind = ,     F4, exec, ~/.config/hypr/scripts/walker-windows.sh
bind = ,     F5, exec, ~/.config/hypr/scripts/walker-switchboard.sh

# --- 4. Special Workspaces (F-Keys) ---
bind = , F1, workspace, 6
bind = , F1, exec, keepassxc
bind = , F9, workspace, 7
bind = , F9, exec, omarchy-launch-webapp https://music.youtube.com/

# --- 5. Shell & UI Switchboard (Physical G-Keys) ---
bind = , XF86Tools,   exec, ~/.config/hypr/scripts/w-toggle.sh   # G1
bind = , XF86Launch5, exec, ~/.config/hypr/scripts/veo-toggle.sh # G2
bind = , XF86Launch6, exec, ~/.config/hypr/scripts/f-toggle.sh   # G3
bind = , XF86Launch7, exec, ~/.config/hypr/scripts/c-toggle.sh   # G4
bind = , XF86Launch8, exec, ~/.config/hypr/scripts/n-toggle.sh   # G5
bind = , XF86Launch9, exec, ~/.config/hypr/scripts/d-toggle.sh   # G6

# --- 6. Navigation & Layout ---
bind = CTRL,  Left,  movefocus, l
bind = CTRL,  Right, movefocus, r
bind = SHIFT, Left,  swapwindow, l
bind = SHIFT, Right, swapwindow, r

# --- 7. Resizing & Moving (WASD/Z) ---
binde = SUPER CTRL, W, resizeactive, 0 -100
binde = SUPER CTRL, A, resizeactive, -100 0
binde = SUPER CTRL, S, resizeactive, 0 100
binde = SUPER CTRL, D, resizeactive, 100 0
binde = SUPER ALT,  W, moveactive, 0 -50
binde = SUPER ALT,  Z, moveactive, 0 50
binde = SUPER ALT,  A, moveactive, -50 0
binde = SUPER ALT,  D, moveactive, 50 0

# --- 8. Screenshots ---
bind = ,      Print, exec, pkill slurp; grimblast --notify copysave area
bind = SHIFT, Print, exec, grimblast --notify copysave screen
bind = CTRL,  Print, exec, pkill slurp; grimblast --notify --freeze copysave area

# --- 9. Workspace Management ---
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = 3, persistent:true
workspace = 4, persistent:true
workspace = 5, persistent:true

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

# Disable Mouse Back/Forward
bind = , mouse:275, exec, 
bind = , mouse:276, exec,

# --- 10. Window Rules (Floating & Pinned) ---
windowrule = match:title ^(floating_kitty)$, float on
windowrule = match:title ^(floating_kitty)$, center on
windowrule = match:title ^(floating_kitty)$, size 875 600

windowrule = float on, match:class ^(xdg-desktop-portal-gtk)$
windowrule = size 875 600, match:class ^(xdg-desktop-portal-gtk)$
windowrule = center on, match:class ^(xdg-desktop-portal-gtk)$
windowrule = float on, match:title ^(Open File|Save As|File Upload)$

windowrule = float 1, match:class ^(calendar-pwa)$
windowrule = size 180 185, match:class ^(calendar-pwa)$
windowrule = move 40 510, match:class ^(calendar-pwa)$
windowrule = pin 1, match:class ^(calendar-pwa)$
```


`looknfeel.conf `
```bash
wip

## --- System & UI ---
alias c='clear'
alias ff='fastfetch'
alias hc='hyprctl clients'

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
alias or='sudo /home/j5/.config/hypr/scripts/omarchy-restore.sh'

# Search history with FZF (if you have fzf installed)
alias hs='history | fzf --tac --no-sort | cb copy'

# Keep only the last 5000 lines and wipe the rest manually
alias xclean-h='sed -i -e :a -e "$q;N;5001,$D;ba" ~/.bash_history'

## --- Snapper Management ---
alias ss='~/.config/hypr/scripts/snap.sh'
alias sl='sudo snapper list'
alias sd='sudo snapper delete'
