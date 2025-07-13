# Using Legacy (v0.12) and Modern (v0.13) Waybar Themes

Waybar v0.13 introduced breaking changes, making some older themes incompatible. This guide explains how to run both Waybar v0.12 (for legacy themes) and v0.13 (for modern themes) simultaneously.

The master script that launches Waybar will be modified to automatically detect which version a theme needs.

### Step 1: Install Waybar v0.12 Locally

First, ensure the latest Waybar is installed from the official repositories:
```bash
sudo pacman -Syu waybar
```

Next, we will extract the older, cached v0.12 package into your local user directory. This will not conflict with the system package.

```bash
# Extract the cached package (NOTE: Adjust the filename if yours is different)
tar -xf /var/cache/pacman/pkg/waybar-0.12.0-1-x86_64.pkg.tar.zst -C ~ --strip-components=1 usr/

# Rename the local binary to avoid conflicts
mv ~/.local/bin/waybar ~/.local/bin/waybar-0.12
```

Verify that both versions are now callable:
```bash
waybar --version       # Should report v0.13.0
waybar-0.12 --version  # Should report v0.12.0
```

### Step 2: Tag Your Legacy Themes

The launch script will identify a legacy theme by looking for a hidden file named `.legacy` inside the theme's folder. The themes are located in `~/.config/waybar/themes/`.

For each of your themes that requires Waybar v0.12, create this file:
```bash
# Example for a theme named 'retro-wave'
touch ~/.config/waybar/themes/retro-wave/.legacy```

### Step 3: Update the Waybar Launch Script

The script that controls the launching of Waybar is `~/.config/waybar/launch.sh`. We will replace its contents with a new version that preserves all its original logic while adding the ability to switch Waybar versions.

First, back up the original file just in case:
```bash
mv ~/.config/waybar/launch.sh ~/.config/waybar/launch.sh.bak
```

Now, completely replace the contents of `~/.config/waybar/launch.sh` with the following code:

```bash
#!/bin/bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#
# by Stephan Raabe (2024)
# MODIFIED to support multiple Waybar versions
# -----------------------------------------------------

# Quit all running waybar instances (both old and new)
pkill waybar
pkill waybar-0.12
sleep 0.2

# -----------------------------------------------------
# Default theme: /THEMEFOLDER;/VARIATION
# -----------------------------------------------------
themestyle="/ml4w-modern;/ml4w-modern/light"

# -----------------------------------------------------
# Get current theme information from ~/.config/ml4w/settings/waybar-theme.sh
# -----------------------------------------------------
if [ -f ~/.config/ml4w/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/ml4w/settings/waybar-theme.sh)
else
    touch ~/.config/ml4w/settings/waybar-theme.sh
    echo "$themestyle" >~/.config/ml4w/settings/waybar-theme.sh
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle="/ml4w;/ml4w/light"
fi

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------
config_file="config"
style_file="style.css"

if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi

# -----------------------------------------------------
#
#  NEW LOGIC: Determine which Waybar executable to use
#
# -----------------------------------------------------
WAYBAR_CMD="waybar"
THEME_PATH="$HOME/.config/waybar/themes${arrThemes[0]}"
if [ -f "$THEME_PATH/.legacy" ]; then
    echo ":: Legacy theme detected, using Waybar v0.12"
    WAYBAR_CMD="waybar-0.12"
fi
# -----------------------------------------------------

# Check if waybar-disabled file exists
if [ ! -f $HOME/.config/ml4w/settings/waybar-disabled ]; then
    # Launch the correct Waybar version with the correct theme
    ${WAYBAR_CMD} -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
else
    echo ":: Waybar disabled"
fi
```

Finally, make sure the new script is executable:
```bash
chmod +x ~/.config/waybar/launch.sh
```
