#!/bin/bash
sleep 0.5  # Optional: Delay before executing the terminal
kitty --class wttr-floating -e zsh -c "
  curl --max-time 10 wttr.in || echo 'Failed to fetch weather'; 
  echo 'Press Enter to exit'; 
  read"




