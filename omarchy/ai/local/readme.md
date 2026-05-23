### llmsum.py

<img alt="20260523_130324" src="https://github.com/user-attachments/assets/85ef1d61-193e-4334-8ed8-c37f8bf4a5fd" />
<br><br>

> Minimal Model: Qwen3.5-2B-UD-Q4_K_XL

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



