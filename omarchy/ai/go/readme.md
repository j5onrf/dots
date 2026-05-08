<img width="3440" height="1440" alt="20260507_160050" src="https://github.com/user-attachments/assets/7196fc26-e5e4-4600-ae18-48eb7e329434" />

```bash
bind = , F8, exec, uwsm app -- alacritty --title "Qwen-Fast" -e sh -c "stty -echoctl; until /home/j5/.config/hypr/scripts/go/qwen-logic; do echo 'Engine crashed, restarting...'; sleep 1; done"
