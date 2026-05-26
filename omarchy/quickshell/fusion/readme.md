# Shell-Fusion | Omarchy

Minimalist industrial vertical UI for Hyprland & Omarchy

<img alt="20260522_013112" src="https://github.com/user-attachments/assets/14c78178-7cdf-4e52-871f-321267333a59" />

`omarchy v3.8.0` `quickshell` `ttf-material-symbols-variable-git`
<br><br>

> *Real-time color injection based on your current Omarchy `.toml`*

```bash
# Kitty Calendar Rules
windowrule = float 1, match:class ^(calendar-pwa)$
windowrule = size 180 185, match:class ^(calendar-pwa)$
windowrule = move 40 510, match:class ^(calendar-pwa)$
windowrule = pin 1, match:class ^(calendar-pwa)$

# Workspace Assignments (KeePass & Music)
bind = , F1, workspace, 6
bind = , F1, exec, keepassxc
bind = Super, M, workspace, 7
bind = Super, M, exec, brave-origin-beta --user-data-dir="/home/j5/.config/brave-spotify-bunker" --app=https://open.spotify.com/
# bind = , F9, workspace, 7
# bind = , F9, exec, omarchy-launch-webapp https://music.youtube.com/
```
```bash
# Auto-hide Tweak
layerrule = match:namespace fusion-shell, no_anim on
```
```
# Quickshell Theme Sync
# To automate Quickshell bar reloads on theme changes, append the reload script to the Omarchy master setter:

echo "~/.config/hypr/scripts/f-reload.sh &" >> ~/.local/share/omarchy/bin/omarchy-theme-set
```
---
