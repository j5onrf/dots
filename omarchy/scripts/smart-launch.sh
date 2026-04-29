#!/bin/bash

# $1 is the class/command
# $2 is optional (use it only if the launch command is different from the class)
CLASS=$1
CMD=${2:-$1}

if hyprctl clients | grep -q "class: $CLASS"; then
    hyprctl dispatch focuswindow class:"$CLASS"
else
    uwsm app -- $CMD
fi
