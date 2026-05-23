#!/usr/bin/env python3
# AI Summary CLI v1.0.4-local (with KoKo Read-Aloud) [2026-05-23]

import sys
import os
import tty
import termios
import urllib.request
import urllib.error
import json
import select
import subprocess
import shutil

# --- Configuration ---
# Llama.cpp server default OpenAI-compatible endpoint
LOCAL_API_URL = "http://localhost:8080/v1/chat/completions"

# Global state for the Text-to-Speech toggle
TTS_ENABLED = True

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
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == '\033':
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
    sys.stdout.write(prompt)
    sys.stdout.write("\n\033[90m[Copy your transcript, text, or PDF to clipboard, then press Enter here to submit]\033[0m\n\n")
    sys.stdout.flush()
    
    sys.stdin.readline()
    
    user_text = ""
    try:
        if shutil.which("wl-paste"):
            user_text = subprocess.check_output(["wl-paste"], text=True)
        else:
            raise Exception("No clipboard utility found (install wl-clipboard).")
            
    except Exception as e:
        sys.stdout.write(f"\033[91m[Clipboard Error: {str(e)}]\033[0m\n")
        sys.stdout.flush()
        return ""

    return user_text.strip()

def check_server_status():
    """Quickly pings the local llama-server to see if it's accepting connections."""
    url = "http://localhost:8080/v1/models"
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=0.5) as _:
            return "\033[1;32m[● ONLINE]\033[0m"
    except Exception:
        return "\033[1;31m[○ OFFLINE] (Press F8)\033[0m"
            
def print_header():
    c = [f"\033[3{i}m" for i in range(1, 6)]
    reset = "\033[0m"
    print(f"         {c[0]}▄████████▄{reset}\n"
          f"       {c[1]}▄████▀  ▀████▄{reset}\n"
          f"     {c[2]}▄████▀  ▄▄  ▀████▄{reset}\n"
          f"    {c[3]}█████   ████   █████{reset}\n"  # Perfect Symmetry
          f"     {c[4]}▀████▄  ▀▀  ▄████▀{reset}\n"
          f"       {c[0]}▀████▄  ▄████▀{reset}\n"
          f"         {c[1]}▀████████▀{reset}\n")

def run_menu():
    global TTS_ENABLED
    keys = list(PROMPT_PROFILES.keys())
    options = [PROMPT_PROFILES[k]["name"] for k in keys] + ["Exit"]
    selected = 0
    
    sys.stdout.write("\033[?25l")
    sys.stdout.flush()
    
    try:
        while True:
            sys.stdout.write("\033[H\033[J")
            print_header()
            
            server_status = check_server_status()
            tts_status = "\033[1;32m[TTS: ON]\033[0m" if TTS_ENABLED else "\033[1;31m[TTS: OFF]\033[0m"
            print(f" Welcome to the AI Summary CLI.           Status: {server_status}  {tts_status}")
            print(" Use arrow keys to navigate, Enter to select, 't' to toggle speech\n")
            
            for i, opt in enumerate(options):
                print(f"{' >' if i == selected else '  '} {opt}")
            sys.stdout.flush()
            
            key = get_key()
            if key == '\033[A': 
                selected = (selected - 1) % len(options)
            elif key == '\033[B': 
                selected = (selected + 1) % len(options)
            elif key.lower() == 't': 
                TTS_ENABLED = not TTS_ENABLED
            elif key == '\r': 
                return selected, keys
    finally:
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()

def call_local_llm(user_input, system_prompt):
    """Sends the summary payload directly to llama.cpp's OpenAI endpoint."""
    data = {
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Content to summarize:\n\n{user_input}"}
        ],
        "temperature": 0.3
    }
    
    req = urllib.request.Request(
        LOCAL_API_URL, 
        data=json.dumps(data).encode(), 
        headers={'Content-Type': 'application/json'}
    )
    
    try:
        with urllib.request.urlopen(req) as res:
            response_json = json.loads(res.read().decode())
            return response_json['choices'][0]['message']['content']
    except urllib.error.URLError as e:
        raise Exception(f"Connection to backend failed. (Is your server online? {e.reason})")

def speak_text(text):
    if not TTS_ENABLED or not text:
        return
    print("\n\033[90m[Generating text-to-speech with KoKo...]\033[0m")
    try:
        koko_cmd = ["koko", "--style", "am_echo", "--speed", "1.15", "text", text, "-o", "/dev/shm/tts.wav"]
        play_cmd = ["pw-play", "/dev/shm/tts.wav"]
        
        subprocess.run(koko_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        subprocess.run(play_cmd, check=True)
    except Exception as e:
        print(f"\033[91m[TTS Error: {e}]\033[0m")

def main():
    while True:
        idx, keys = run_menu()
        if idx == len(keys): break
        
        choice = keys[idx]
        sys.stdout.write("\033[H\033[J")
        print_header()
        
        user_input = get_input_or_escape(f"\033[1;32m{PROMPT_PROFILES[choice]['name']} ❯\033[0m ")
        
        if user_input:
            print("\nProcessing request locally via llama.cpp...")
            try:
                summary = call_local_llm(user_input, PROMPT_PROFILES[choice]['prompt'])
                print(f"\n{summary}")
                speak_text(summary)
                
            except Exception as e:
                print(f"\n❌ Local LLM Error: {e}")
                print("\033[1;33mEnsure your llama.cpp server is running. Press F8 to launch it!\033[0m")
            flush_input_buffer()
            input("\nPress Enter to return to menu.")

if __name__ == "__main__":
    main()
