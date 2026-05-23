<img alt="20260522_211506" src="https://github.com/user-attachments/assets/412689f3-3dbe-417f-a4a2-80dfff2e8609" />
<br><br>

```ini
# --- Launch a transient Antigravity CLI ---
bind = SUPER, X, exec, kitty sh -c '$HOME/.config/hypr/scripts/ai/agy/ytsum.py'
```

```ini
# --- Optimized Neural Kokoro TTS Reader ---
bind = SUPER SHIFT, R, exec, bash -c 'TEXT=$(wl-paste --primary); [ -n "$TEXT" ] && koko --style am_echo --speed 1.15 text "$TEXT" -o /dev/shm/tts.wav && pw-play /dev/shm/tts.wav'

# --- Kill TTS Audio Output Instantly ---
bind = SUPER SHIFT, X, exec, pkill -9 -f "pw-play|koko"
```


