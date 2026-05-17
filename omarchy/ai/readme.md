<img alt="logo" src="https://github.com/user-attachments/assets/96ffa0ac-fe73-4edd-b81f-f6fe6db94e2b" />


### Qwen 3.6:35b-a3b Q4_K_M (4-bit)

> testing (llama.cpp c++) <br>
> Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ4_NL <br>
> Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced-Q4_K_P
> 
**The "Active-3B" Sparse Expert**

Released on **April 14, 2026**, this model is the absolute gold standard for high-intelligence local inference on standard consumer hardware.

A frontier-class Mixture-of-Experts (MoE) model designed for high-speed local inference. It provides 35B-level logic with the resource footprint of a 3B model.

*   **Intelligence:** 35B total parameters for high-fidelity reasoning and coding.
*   **Speed:** Only **3B parameters active** per token, ensuring 10+ TPS even on mid-range CPUs.
*   **Efficiency:** Optimized for low-bandwidth memory (DDR4/DDR5) and non-GPU environments.
*   **Capability:** Native 262k context; excels at "Thinking" tasks and agentic workflows.
*   **Optimization:** Best run with `--reasoning off` for instant, deterministic micro-agent responses.

---

### The A3B Architecture (Active 3 Billion)

The secret to its speed is the **Hybrid Sparse Mixture-of-Experts (MoE)** architecture.

*   **Total Knowledge:** 35 Billion parameters.
*   **Active Brain:** Only **3 Billion parameters** activate per token.
*   **Expert Routing:** 256 independent experts; it only fires the specific experts needed for the task.
*   **Efficiency:** You get **35B-level reasoning** with the RAM impact and speed of a **3B model**.

---

### Top Features in 3.6

*   **Agentic Coding Power:** Specifically optimized for repository-level reasoning and frontend workflows.
*   **Native Multimodal:** Built from day one to process text, images, and video natively.
*   **Massive Context:** Supports **262,144 tokens** natively, extensible to 1M+.
*   **Decisive Output:** Significant reductions in "looping" and overthinking compared to the 3.5 series.

---

### Why it's the best for CPU right now

It breaks the scaling myth. Because only 3B parameters are active per forward pass, it is bottlenecked by **memory bandwidth** (RAM speed) rather than raw CPU compute. On a setup with fast DDR4/DDR5, it provides frontier-class intelligence without the sub-1 token/s crawl of dense 35B models.

---

### ⚙️ Universal Hardware Configuration

| Setting | Value | Rationale |
| :--- | :--- | :--- |
| **`num_thread`** | Core Count | Match **physical** core count (not threads) for optimal cache usage. |
| **`temperature`** | 0.0 - 1.0 | Required for deterministic micro-agent accuracy. |
| **`num_ctx`** | 4096+ | Adjust based on RAM; `/clear` after topics to maintain speed. |
| **`Architecture`** | MoE | Hybrid Gated DeltaNet scales across Intel/AMD architectures. |

---

### CPU Management (Chill Governor)

For added stability, a toggle script can be used to manage CPU governors. This allows you to switch to a "chill" mode—capping frequencies to keep fans and temperatures down during long inference sessions—or a performance mode when raw speed is required.

---

### Hyprland Keybind

```ini
# --- AI / Qwen-35b ---
bind = , F9, exec, uwsm app -- foot sh -c 'echo "Loading IQ4_NL in Direct Non-Thinking Mode..." && llama-cli -m /home/j5/ollama_backup/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ4_NL.gguf -c 4096 -t 6 -b 128 --cache-type-k q4_0 --cache-type-v q8_0 --reasoning off --jinja --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --presence-penalty 1.5 -sys "Concise and direct. No preamble."; exec bash'

# --- AI / Qwen-35b (WebUI) ---
bind = , F9, exec, uwsm app -- sh -c 'llama-server -m /home/j5/ollama_backup/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ4_NL.gguf -c 4096 -t 6 -b 512 --cache-type-k q4_0 --cache-type-v q4_0 --reasoning off --flash-attn on --parallel 1 --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 1.5 --port 8080 & sleep 1.5 && exec xdg-open "http://localhost:8080"'
```
```ini
# --- AI / Gemma4-26b ---
bind = , F8, exec, uwsm app -- kitty sh -c 'echo "Loading Gemma4 K_P MoE in Instant Non-Thinking Mode..." && llama-cli -m /home/j5/ollama_backup/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced-Q4_K_P.gguf -c 8192 -t 6 -b 128 --cache-type-k q4_0 --cache-type-v q8_0 --reasoning off --jinja --chat-template-kwargs "{\"enable_thinking\": false}" --temp 1.0 --top-p 0.95 --top-k 64 --min-p 0.0 --presence-penalty 0.0 -sys "Concise and direct. No preamble."; exec bash'

# --- AI / Gemma4-26b (WebUI) ---
bind = , F8, exec, uwsm app -- sh -c 'llama-server -m /home/j5/ollama_backup/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced-Q4_K_P.gguf -c 8192 -t 6 -b 512 --cache-type-k q4_0 --cache-type-v q8_0 --reasoning off --jinja --chat-template-kwargs "{\"enable_thinking\": false}" --temp 1.0 --top-p 0.95 --top-k 64 --min-p 0.0 --presence-penalty 0.0 --port 8080 & sleep 1.5 && exec xdg-open "http://localhost:8080"'
```
---

### Optimized Modelfile

```dockerfile

wip




