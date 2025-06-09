#!/bin/bash

# Set the resolution for your 4K TV after applying the 1.333333 scale (2880x1620)
res_w=2880   # Width after scaling
res_h=1620   # Height after scaling

# Calculate the vertical margin as a percentage of the height
w_margin_v=$(( res_h * 27 / 100 ))  # Vertical margin as 27% of the scaled height

# Increase horizontal margin by adjusting the width proportionally
w_margin_h=$(( res_w * 25 / 100 ))  # Horizontal margin as 25% of the scaled width

# Launch wlogout with the calculated margins
wlogout -b 5 -T $w_margin_v -B $w_margin_v -L $w_margin_h -R $w_margin_h

