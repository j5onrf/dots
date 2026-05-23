#!/usr/bin/env python3
# --- AntiGravity-CLI YouTube Summary / KoKo Read Aloud / v0.2 beta 5-22-26 ---

import sys
import os
import tty
import termios
import urllib.request
import json
import select

# --- Configuration ---
API_KEY = "api-key-here"

PROMPT_PROFILES = {
    "1": {
        "name": "1. Core Takeaways (Direct & Punchy Baseline)",
        "prompt": (
            "Summarize the provided content using exactly 5 to 10 structural bullet points. "
            "CRITICAL FORMATTING RULES:\n"
            "1. Focus strictly on core concepts, arguments, and practical takeaways.\n"
            "2. Do NOT include any timestamps (e.g., no [MM:SS]), runtimes, or chronological segment numbers.\n"
            "3. Output ONLY the clean markdown bullet points. Keep sentences punchy, scannable, and distraction-free."
        )
    },
    "2": {
        "name": "2. Broad Big Picture (Chronological Chunking)",
        "prompt": (
            "Act as a broad-perspective content summarizer. Break down the entire content "
            "intellectually into equally-sized chronological chunks (sections). For each chunk, "
            "provide a single, clean, high-level structural takeaway bullet point. "
            "CRITICAL RULE: Focus on the big picture, covering the entire scope broadly without "
            "getting bogged down in minutiae. Do NOT include any timestamps."
        )
    },
    "3": {
        "name": "3. Executive Synthesis (High-Level + Deep Breakdown)",
        "prompt": (
            "Provide a two-tiered executive synthesis of the content:\n"
            "1. First, provide a brief, 2-3 sentence high-level executive summary summarizing the main thesis.\n"
            "2. Second, provide 5-8 detailed, nested bullet points breaking down the primary supporting arguments "
            "and structural themes.\n"
            "CRITICAL RULE: Do NOT include any timestamps or chronological tracking metrics."
        )
    },
    "4": {
        "name": "4. Detail-Oriented Focus (Technical & Tactical Nuances)",
        "prompt": (
            "Act as a detail-oriented analyst. Focus heavily on deep details, specific examples, "
            "tactical methods, and step-by-step nuances found from start to finish. "
            "Provide 5 to 10 highly specific, detailed structural bullet points capturing "
            "the explicit mechanics of the discussion. Do NOT include any timestamps."
        )
    },
    "5": {
        "name": "5. Comprehensive Breakdown (Exhaustive Full Transcript)",
        "prompt": (
            "Act as a comprehensive documentation engine. Synthesize the entire content/transcript "
            "into an exhaustive, complete summary framework. Provide a structured 5 to 10 bullet point "
            "breakdown that guarantees no major argument, conclusion, or piece of context from the "
            "entire runtime is missed. Keep it clean and scannable. Do NOT include any timestamps."
        )
    }
}

# --- TUI & Display Logic ---
def get_key():
    """Restored: Using your original reliable key-reading logic."""
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == '\033':
            # This read(2) covers standard arrow keys \033[A, B, C, D
            ch += sys.stdin.read(2)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

def flush_input_buffer():
    try:
        termios.tcflush(sys.stdin, termios.TCIFLUSH)
    except Exception:
        pass

def get_input_or_escape(prompt):
    import subprocess
    import shutil

    sys.stdout.write(prompt)
    sys.stdout.write("\n\033[90m[Copy your transcript to clipboard, then press Enter here to submit]\033[0m\n\n")
    sys.stdout.flush()
    
    # Wait for the user to press Enter to confirm they've copied the text
    sys.stdin.readline()
    
    # Detect the system's clipboard utility
    user_text = ""
    try:
        if shutil.which("wl-paste"):  # Wayland native
            user_text = subprocess.check_output(["wl-paste"], text=True)
        elif shutil.which("xclip"):   # X11 native
            user_text = subprocess.check_output(["xclip", "-selection", "clipboard", "-o"], text=True)
        elif shutil.which("xsel"):    # X11 alternative
            user_text = subprocess.check_output(["xsel", "--clipboard", "--output"], text=True)
        else:
            raise Exception("No clipboard utility found (install xclip or wl-clipboard).")
            
    except Exception as e:
        sys.stdout.write(f"\033[91m[Clipboard Error: {str(e)}]\033[0m\n")
        sys.stdout.flush()
        return ""

    return user_text.strip()
            
def print_header():
    c = [f"\033[3{i}m" for i in range(1, 6)]
    reset = "\033[0m"
    print(f"        {c[0]}▄██▄{reset}\n"
          f"       {c[1]}██████{reset}\n"
          f"      {c[2]}████████{reset}\n"
          f"     {c[3]}███▀  ▀███{reset}\n"
          f"    {c[4]}▄██▀    ▀██▄{reset}\n")

def run_menu():
    keys = list(PROMPT_PROFILES.keys())
    options = [PROMPT_PROFILES[k]["name"] for k in keys] + ["Exit"]
    selected = 0
    
    # Hide the cursor
    sys.stdout.write("\033[?25l")
    sys.stdout.flush()
    
    try:
        while True:
            sys.stdout.write("\033[H\033[J")
            print_header()
            print(" Welcome to the Antigravity CLI.\n Use arrow keys to navigate, Enter to select\n")
            for i, opt in enumerate(options):
                print(f"{' >' if i == selected else '  '} {opt}")
            sys.stdout.flush()
            
            key = get_key()
            if key == '\033[A': selected = (selected - 1) % len(options)
            elif key == '\033[B': selected = (selected + 1) % len(options)
            elif key == '\r': return selected, keys
    finally:
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()

def call_gemini(user_input, system_prompt):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={API_KEY}"
    full_text = f"Instruction: {system_prompt}\n\nContent:\n{user_input}"
    data = {"contents": [{"parts": [{"text": full_text}]}]}
    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as res:
        return json.loads(res.read().decode())['candidates'][0]['content']['parts'][0]['text']

def main():
    while True:
        idx, keys = run_menu()
        if idx == len(keys): break
        
        choice = keys[idx]
        sys.stdout.write("\033[H\033[J")
        print_header()
        
        user_input = get_input_or_escape(f"\033[1;32m{PROMPT_PROFILES[choice]['name']} ❯\033[0m ")
        
        if user_input:
            print("\nProcessing request...")
            try:
                print(f"\n{call_gemini(user_input, PROMPT_PROFILES[choice]['prompt'])}")
            except Exception as e:
                print(f"\n❌ Error: {e}")
            flush_input_buffer()
            input("\nPress Enter to return to menu.")

if __name__ == "__main__":
    main()
