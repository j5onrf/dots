# Qwen-36B AI Assistant Trigger
```ini
bind = , F8, exec, uwsm app -- alacritty --title "Qwen-35b" -e ollama run qwen36-35b-a3b:latest --think=false --verbose
```
## Qwen 3.6 35B-A3B: The "No-GPU" Frontier

Released on **April 14, 2026**, this model is the absolute gold standard for high-intelligence local inference on standard consumer hardware. 

### The A3B Architecture (Active 3 Billion)
The "A3B" designation is the secret to its speed. It uses a **Hybrid Sparse Mixture-of-Experts (MoE)** architecture.
*   **Massive Library:** Contains **35 Billion total parameters** sitting in its weights.
*   **Surgical Precision:** It only activates **3 Billion parameters** per token.
*   **Expert Routing:** Uses **256 independent experts**, but only 9 (8 routed + 1 shared) process any single request.
*   **The Benefit:** You get the deep world knowledge of a 35B model at the **compute cost and speed of a 3B model**.

### Top Features in 3.6
*   **Agentic Coding Power:** Optimized for repository-level reasoning and frontend workflows, outperforming much larger dense models on coding benchmarks.
*   **Multimodal Native:** Native support for text, image, and video inputs without needing external adapters.
*   **Massive Context:** Supports **262,144 tokens** natively, extensible to over **1 million** via YaRN.
*   **Thinking Preservation:** Includes an integrated "thinking mode" that preserves reasoning traces across multi-turn conversations.

### Why it's the best for CPU right now
It breaks the scaling myth. Because only 3B parameters are active per forward pass, it is bottlenecked by **memory bandwidth** rather than raw CPU compute (FLOPs). On a pure CPU setup, it can reach **20+ tokens/s** depending on your RAM speed (DDR5).

---

### Optimized Modelfile
```dockerfile
FROM qwen3.6:35b-a3b

# Forces the context window to 1024 to save RAM (optional)
PARAMETER num_ctx 1024

# Set to your PHYSICAL core count (e.g., 1 per core)
PARAMETER num_thread 8

# Optimized for logic-heavy tasks
PARAMETER temperature 0
PARAMETER top_k 1
PARAMETER top_p 0.1

SYSTEM "START IMMEDIATELY. NO THINKING."

```
