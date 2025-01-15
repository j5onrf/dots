#!/bin/bash

# Set the effective resolution based on your TV's 1.6 scale
res_w=2400  # Width after scaling
res_h=1350  # Height after scaling

# Calculate the vertical margin as a percentage of the height
w_margin_v=$(( res_h * 27 / 100 ))  # Vertical margin as 27% of the height

# Calculate the horizontal margin as a percentage of the width
w_margin_h=$(( res_w * 25 / 100 ))  # Horizontal margin as 25% of the width

# Launch wlogout with the calculated margins
wlogout -b 5 -T $w_margin_v -B $w_margin_v -L $w_margin_h -R $w_margin_h

