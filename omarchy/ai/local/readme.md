### llmsum.py

<img width="3440" height="1440" alt="20260523_212452" src="https://github.com/user-attachments/assets/9cc0410b-df6e-44f3-bf50-bbf9e1ef144e" />
<br><br>

> Qwen3.5-2B-UD-Q4_K_XL

```ini
# --- Launch a transient AI Summary CLI  ---
bind = SUPER, X, exec, kitty sh -c '/home/j5/.config/hypr/scripts/ai/llm/llmsum.py'
```

```ini
# --- Optimized Neural Kokoro TTS Reader ---
bind = SUPER SHIFT, R, exec, bash -c 'TEXT=$(wl-paste --primary); [ -n "$TEXT" ] && koko --style am_echo --speed 1.15 text "$TEXT" -o /dev/shm/tts.wav && pw-play /dev/shm/tts.wav'

# --- Kill TTS Audio Output Instantly ---
bind = SUPER SHIFT, X, exec, pkill -9 -f "pw-play|koko"
```



