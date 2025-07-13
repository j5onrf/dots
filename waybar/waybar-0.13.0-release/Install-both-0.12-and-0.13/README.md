# Using Legacy (v0.12) and Modern (v0.13) Waybar Themes

Waybar v0.13 introduced breaking changes, making some older themes incompatible. This guide explains how to run both Waybar v0.12 (for legacy themes) and v0.13 (for modern themes) simultaneously.

The Rofi theme switcher script will be modified to automatically detect which version a theme needs.

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

The theme switcher script will identify a legacy theme by looking for a hidden file named `.legacy` inside the theme's folder.

For each of your themes that requires Waybar v0.12, create this file:
```bash
# Example for a theme named 'retro'
touch ~/.config/waybar/themes/retro/.legacy
```

### Step 3: Update the Theme Switcher Script

Modify `~/.config/rofi/waybar/themes.sh` to add the version-selection logic.

Find this block of code at the end of the script:
```bash
# Original code to replace
ln -sf "$dir/$theme/config" "$HOME/.config/waybar/config"
ln -sf "$dir/$theme/style.css" "$HOME/.config/waybar/style.css"

pkill waybar
waybar &
```

And replace it with this new block:
```bash
# New code with version-switching logic
ln -sf "$dir/$theme/config" "$HOME/.config/waybar/config"
ln -sf "$dir/$theme/style.css" "$HOME/.config/waybar/style.css"

# Set default command and check for legacy tag
WAYBAR_CMD="waybar"
if [ -f "$dir/$theme/.legacy" ]; then
    WAYBAR_CMD="waybar-0.12"
fi

# Kill all instances and launch the correct version
pkill waybar
pkill waybar-0.12
${WAYBAR_CMD} &
```

---

That's it. Your Rofi theme selector will now automatically launch the correct Waybar version based on the theme you choose.
