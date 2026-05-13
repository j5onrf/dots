# Shell-Fusion | Omarchy

> **Minimalist industrial vertical UI for Hyprland & Omarchy**

`Porting to Noctalia v5 architecture, Fusion-Shell will no longer be a standalone QML script. Instead, it will be a Scripted Widget or a C++ Module`

`Omarchy v3.8.0` `quickshell` `ttf-material-symbols-variable-git`

<img alt="20260429_200056" src="https://github.com/user-attachments/assets/852add48-aeb3-4d7b-8d5e-a5f3a1fdaff3" />
<br><br>

> *Real-time color injection based on your current Omarchy `.toml`*

```bash
# Kitty Calendar Rules
windowrule = float 1, match:class ^(calendar-pwa)$
windowrule = size 180 185, match:class ^(calendar-pwa)$
windowrule = move 40 510, match:class ^(calendar-pwa)$
windowrule = pin 1, match:class ^(calendar-pwa)$

# Workspace Assignments (KeePass & Music)
windowrule = match:class ^(org.keepassxc.KeePassXC)$, workspace 6 silent
windowrule = match:class ^(brave-music.youtube.com__-Default)$, workspace 7 silent
```
```bash
# Pin the Quickshell bar for auto-hide
layerrule = match:namespace fusion-shell, no_anim on
```
```
# Quickshell Theme Sync
# To automate Quickshell bar reloads on theme changes, append the reload script to the Omarchy master setter:

echo "~/.config/hypr/scripts/f-reload.sh &" >> ~/.local/share/omarchy/bin/omarchy-theme-set
