# Shell-Fusion | Omarchy

> **Minimalist industrial vertical UI for Hyprland & Omarchy**

`Omarchy v3.8.0` `quickshell` `ttf-material-symbols-variable-git` `Porting to Omarchy-shell`

<img alt="20260522_002417" src="https://github.com/user-attachments/assets/04d0ec99-d0aa-42d5-814b-19c5ed60ba10" />
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
