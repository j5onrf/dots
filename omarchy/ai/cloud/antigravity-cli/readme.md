### ytsum.py

<img alt="20260522_232208" src="https://github.com/user-attachments/assets/51b26fd7-cd39-47b0-b1d0-48c93bbab426" />
<br><br>

```ini
# --- Launch a transient Antigravity CLI ---
bind = SUPER, X, exec, kitty sh -c '$HOME/.config/local-iq/antigravity-cli/ytsum.py'
```

```ini
# --- Optimized Neural Kokoro TTS Reader ---
bind = SUPER SHIFT, R, exec, bash -c 'TEXT=$(wl-paste --primary); [ -n "$TEXT" ] && koko --style am_echo --speed 1.15 text "$TEXT" -o /dev/shm/tts.wav && pw-play /dev/shm/tts.wav'

# --- Kill TTS Audio Output Instantly ---
bind = SUPER SHIFT, X, exec, pkill -9 -f "pw-play|koko"
```


