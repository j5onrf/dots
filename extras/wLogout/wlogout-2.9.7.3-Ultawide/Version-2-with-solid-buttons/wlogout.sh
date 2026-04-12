#!/bin/bash

# Set static resolution values for your ultrawide monitor (example values)
res_w=3440   # Example width for an ultrawide monitor (e.g., 3440x1440)
res_h=1440   # Example height for an ultrawide monitor (e.g., 3440x1440)

# Set the scaling factor manually if needed (adjust as necessary)
h_scale=100  # Set a static scale factor (100 for no scaling)

# Calculate the vertical margin as a percentage of the height
w_margin_v=$(( res_h * 27 / 100 ))  # Vertical margin as 27% of the height

# Increase horizontal margin by adjusting the width proportionally
w_margin_h=$(( res_w * 25 / 100 ))  # Horizontal margin as 25% of the width (increased)

# Launch wlogout with the calculated margins
wlogout -b 5 -T $w_margin_v -B $w_margin_v -L $w_margin_h -R $w_margin_h

