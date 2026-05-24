### llmsum.py

<img alt="20260523_220348" src="https://github.com/user-attachments/assets/fdd2d2b2-d938-4177-8bd2-4cda27668f06" />

`Qwen3.5-2B-UD-Q4_K_XL+` `local-iq`

<br>

> #### Copy your transcript, text, or PDF to clipboard before submitting

```ini
# --- Launch a transient AI Summary TUI  ---
bind = SUPER, X, exec, kitty sh -c '/home/j5/.config/hypr/scripts/ai/llm/llmsum.py'
```

```ini
# --- Optimized Neural Kokoro TTS Reader ---
bind = SUPER SHIFT, R, exec, bash -c 'TEXT=$(wl-paste --primary); [ -n "$TEXT" ] && koko --style am_echo --speed 1.15 text "$TEXT" -o /dev/shm/tts.wav && pw-play /dev/shm/tts.wav'

# --- Kill TTS Audio Output Instantly ---
bind = SUPER SHIFT, X, exec, pkill -9 -f "pw-play|koko"
```



