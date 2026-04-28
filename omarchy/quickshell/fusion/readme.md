# ⚡ Shell-Fusion | Omarchy

> **Minimalist industrial vertical UI for Hyprland & Omarchy**

`Omarchy v3.6.0` `Quickshell 0.2.1+`

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
```markdown
# Quickshell Theme Sync

To automate Quickshell bar reloads on theme changes, append the reload script to the Omarchy master setter:

```bash
echo "~/.config/hypr/scripts/f-reload.sh &" >> ~/.local/share/omarchy/bin/omarchy-theme-set
