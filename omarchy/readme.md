testing veo = vertical omarchy
<img alt="20260423_102651" src="https://github.com/user-attachments/assets/98c9e686-71a8-4d18-9f18-9488cc0f51cc" />

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
bind = SUPER SHIFT, N, exec, omarchy-launch-editor
bind = SUPER, B, exec, hyprctl clients | grep -q "class: brave-origin-beta" && hyprctl dispatch focuswindow class:brave-origin-beta || uwsm app brave-origin-beta.desktop
bind = SUPER, F, exec, hyprctl clients | grep -q "class: org.gnome.Nautilus" && hyprctl dispatch focuswindow class:org.gnome.Nautilus || uwsm app -- nautilus --new-window

# --- Utilities & Clipboard ---
bind = ALT, C, exec, walker -m clipboard
bind = ALT, R, exec, ~/.config/hypr/conf/scripts/toggle_scale.sh
bind = SUPER, H, exec, omarchy-toggle-nightlight

# --- Shell & UI Toggles ---
bind = SUPER, V, exec, ~/.config/hypr/Scripts/veo-toggle.sh
bind = SUPER, X, exec, ~/.config/hypr/Scripts/w-toggle.sh
# bind = SUPER, C, exec, ~/.config/quickshell/caelestia/c-toggle.sh
# bind = SUPER, V, exec, ~/.config/noctalia/n-toggle.sh
# bind = SUPER, B, exec, ~/.config/DankMaterialShell/toggle.sh
# bind = SUPER, Z, exec, ~/.config/quickshell/shell-fusion/toggle.sh

# --- Navigation & Scrolling Layout ---
bind = SUPER SHIFT, A, movefocus, l
bind = SUPER SHIFT, D, movefocus, r
bind = SUPER SHIFT, S, layoutmsg, swapcol r
bind = ALT, comma, exec, hyprctl dispatch layoutmsg colresize all 0.5

# --- Resizing (WASD) ---
binde = SUPER CTRL, A, resizeactive, -100 0
binde = SUPER CTRL, D, resizeactive, 100 0

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
    active_opacity = 2
    inactive_opacity = 2
    fullscreen_opacity = 2

    blur {
        enabled = false
    }

    shadow {
        enabled = false
    }
}

animations {
    enabled = true
    animation = global, 1, 0.5, default
}

scrolling {
    column_width = 0.5
    focus_fit_method = 1
}
```
