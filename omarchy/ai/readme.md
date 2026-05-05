# Qwen-35B AI Assistant Trigger
```ini
bind = , F8, Open Qwen-35b in Alacritty, exec, uwsm app -- alacritty --title "Qwen-35b" -e ollama run qwen36-35b-a3b:latest --think=false --verbose
```
## Qwen 3.5 35B-A3B: The CPU Optimization King

Released on **February 25, 2026**, this model is the current gold standard for high-intelligence local AI without a dedicated GPU.

### The A3B Architecture (Active 3 Billion)
Unlike "dense" models that use every parameter for every word, Qwen 3.5 uses a **Hybrid Sparse Mixture-of-Experts (MoE)**.
*   **Total Knowledge:** 35 Billion parameters in the library.
*   **Active Brain:** Only **3 Billion parameters** fire per token.
*   **Expert Routing:** 256 independent experts; only ~3.5% (9 experts) activate per request.
*   **Efficiency:** You get **35B-level reasoning** at **3B-level speeds**.

### Top Features
*   **Native Multimodal:** Built from day one to "see" images and "understand" video without external adapters.
*   **Massive Context:** Supports **262,144 tokens** natively (extensible to 1M+ via YaRN).
*   **Gated Delta Networks:** High-throughput architecture designed to minimize RAM latency on consumer CPUs.
*   **Built-in Reasoning:** Native "Chain of Thought" traces for complex problem solving.

### Why it's the best right now
It breaks the "RAM vs. Speed" bottleneck. It is the only model providing **frontier-class intelligence** (comparable to GPT-4o) that maintains **6-10 tokens/s to 30–35 tokens/s range** on a mid-range CPU like an i5 or Ryzen 5.

---

### Optimized Modelfile
```dockerfile
FROM qwen3.5:35b-a3b

# Forces the context window to 1024 to save RAM and stop the '2048' default lag (optional for 32gb ram)
PARAMETER num_ctx 1024

# Set to your PHYSICAL core count (e.g., one per core)
PARAMETER num_thread 8

# Optimized for logic-heavy tasks
PARAMETER temperature 0
PARAMETER top_k 1
PARAMETER top_p 0.1

SYSTEM "START IMMEDIATELY. NO THINKING."

```
