# ⚡ Shell-Fusion | Omarchy

> **Minimalist industrial vertical UI for Hyprland & Omarchy**

`Omarchy v3.6.0` `Quickshell 0.2.1+`

<img width="3440" height="1440" alt="20260429_184843" src="https://github.com/user-attachments/assets/987e37b3-d062-474b-b746-b326a253ab3d" />
<br><br>
<img alt="20260426_164415" src="https://github.com/user-attachments/assets/af25b0eb-9fdc-434e-9aa8-d27d317f1a76" />
<br><br>

| Red / Rossetto | Green / Osaka Jade | Blue / Tokyo Night |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/ee2447b0-cd3f-4a5b-abab-17522299a1f0" width="100" /> | <img src="https://github.com/user-attachments/assets/55388b09-bd7d-454d-9f57-28d86bd2fbf3" width="100" /> | <img src="https://github.com/user-attachments/assets/481944d7-8601-41b5-8922-ac2a9fc1fdce" width="100" /> |

*Real-time color injection based on your current Omarchy `.toml`*
<br><br>

```bash
# Kitty Calendar Rules
windowrule = float 1, match:class ^(calendar-pwa)$
windowrule = size 180 185, match:class ^(calendar-pwa)$
windowrule = move 40 510, match:class ^(calendar-pwa)$
windowrule = pin 1, match:class ^(calendar-pwa)$
```
```bash
# Pin the Quickshell bar for auto-hide
layerrule = match:namespace quickshell, no_anim on
```
```
# Quickshell Theme Sync
# To automate Quickshell bar reloads on theme changes, append the reload script to the Omarchy master setter:

echo "~/.config/hypr/scripts/f-reload.sh &" >> ~/.local/share/omarchy/bin/omarchy-theme-set
