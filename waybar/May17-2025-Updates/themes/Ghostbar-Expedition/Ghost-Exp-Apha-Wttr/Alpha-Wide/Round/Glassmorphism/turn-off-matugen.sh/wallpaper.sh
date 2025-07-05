#!/bin/bash
#  _      __     ____                      
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/   
#                /_/       /_/             
# -----------------------------------------------------
# Check to use wallpaper cache
# 2025-07-05 more optimizations
# -----------------------------------------------------

if [ -f ~/.config/ml4w/settings/wallpaper_cache ]; then
    use_cache=1
    echo ":: Using Wallpaper Cache"
else
    use_cache=0
    echo ":: Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0
generatedversions="$HOME/.config/ml4w/cache/wallpaper-generated"
waypaperrunning=$HOME/.config/ml4w/cache/waypaper-running
cachefile="$HOME/.config/ml4w/cache/current_wallpaper"
blurredwallpaper="$HOME/.config/ml4w/cache/blurred_wallpaper.png"
squarewallpaper="$HOME/.config/ml4w/cache/square_wallpaper.png"
rasifile="$HOME/.config/ml4w/cache/current_wallpaper.rasi"
blurfile="$HOME/.config/ml4w/settings/blur.sh"
defaultwallpaper="$HOME/wallpaper/default.jpg"
wallpapereffect="$HOME/.config/ml4w/settings/wallpaper-effect.sh"
blur="50x30"
blur=$(cat $blurfile)

# Ensures that the script only run once if wallpaper effect enabled
if [ -f $waypaperrunning ]; then
    rm $waypaperrunning
    exit
fi

# Create folder with generated versions of wallpaper if not exists
if [ ! -d $generatedversions ]; then
    mkdir $generatedversions
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ]; then
    if [ -f $cachefile ]; then
        wallpaper=$(cat $cachefile)
    else
        wallpaper=$defaultwallpaper
    fi
else
    wallpaper=$1
fi
used_wallpaper=$wallpaper
echo ":: Setting wallpaper with source image $wallpaper"
tmpwallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cachefile ]; then
    touch $cachefile
fi
echo "$wallpaper" >$cachefile
echo ":: Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaperfilename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

if [ -f $wallpapereffect ]; then
    effect=$(cat $wallpapereffect)
    if [ ! "$effect" == "off" ]; then
        used_wallpaper=$generatedversions/$effect-$wallpaperfilename
        if [ -f $generatedversions/$effect-$wallpaperfilename ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
            echo ":: Use cached wallpaper $effect-$wallpaperfilename"
   else
            echo ":: Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"
            notify-send --replace-id=1 "Applying effect: $effect..." "Processing: $wallpaperfilename" -h int:value:30
            source $HOME/.config/hypr/effects/wallpaper/$effect
            notify-send --replace-id=1 "Effect '$effect' applied." "$wallpaperfilename processed." -h int:value:100 -t 4000
        fi
        echo ":: Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
        echo ":: Setting wallpaper with $used_wallpaper"
        touch $waypaperrunning
        waypaper --wallpaper $used_wallpaper
    else
        echo ":: Wallpaper effect is set to off"
    fi
else
    effect="off"
fi

# -----------------------------------------------------
# Execute Matugen & Wallust (if not locked)
# -----------------------------------------------------

# Define the path to the lock file
MATUGEN_LOCK_FILE="$HOME/.config/ml4w/cache/matugen_lock"

# Check if the lock file exists
if [ ! -f "$MATUGEN_LOCK_FILE" ]; then
    # --- IF NOT LOCKED: Run all color generation ---
    echo ":: Matugen is unlocked. Generating new theme..."

    # Execute matugen
    $HOME/.cargo/bin/matugen image $used_wallpaper -m "dark"

    # Execute wallust
    $HOME/.cargo/bin/wallust run $used_wallpaper

else
    # --- IF LOCKED: Skip all color generation ---
    echo ":: Matugen is locked. Skipping color generation."
fi

# --- Apply Matugen theme to VSCodium ---
if [ -f "$HOME/.config/hypr/scripts/vscodium-matugen.sh" ]; then
    echo ":: Applying Matugen theme to VSCodium"
    bash "$HOME/.config/hypr/scripts/vscodium-matugen.sh" & # Run the script w/ minor optimization
else
    echo ":: VSCodium Matugen script not found, skipping."
fi
# --- End of VSCodium section ---

# -----------------------------------------------------
# Execute wallust
# -----------------------------------------------------

# --- Add this section to update Kew colors ---
# KEW_UPDATE_SCRIPT="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/update_kew_colors.sh"
# if [ -f "$KEW_UPDATE_SCRIPT" ]; then
#     echo ":: Updating Kewmusicplayer colors..."
#     # The config file is updated silently in the background. Kew will detect the change automatically.
#     bash "$KEW_UPDATE_SCRIPT" &
# else
#     echo ":: Warning: Kew color update script not found at $KEW_UPDATE_SCRIPT" >&2
# fi
# --- End of Kew color update section ---

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------

sleep 2
$HOME/.config/waybar/launch.sh
# killall -SIGUSR2 waybar

# -----------------------------------------------------
# Reload nwg-dock-hyprland
# -----------------------------------------------------

$HOME/.config/nwg-dock-hyprland/launch.sh &

# -----------------------------------------------------
# Update Pywalfox
# -----------------------------------------------------

if type pywalfox >/dev/null 2>&1; then
    pywalfox update
fi

# -----------------------------------------------------
# Update SwayNC
# -----------------------------------------------------
sleep 0.1
swaync-client -rs

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------

if [ -f $generatedversions/blur-$blur-$effect-$wallpaperfilename.png ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
    echo ":: Use cached wallpaper blur-$blur-$effect-$wallpaperfilename"
else
    echo ":: Generate new cached wallpaper blur-$blur-$effect-$wallpaperfilename with blur $blur"
    # notify-send --replace-id=1 "Generate new blurred version" "with blur $blur" -h int:value:66
    magick $used_wallpaper -resize 75% $blurredwallpaper
    echo ":: Resized to 75%"
    if [ ! "$blur" == "0x0" ]; then
        magick $blurredwallpaper -blur $blur $blurredwallpaper
        cp $blurredwallpaper $generatedversions/blur-$blur-$effect-$wallpaperfilename.png
        echo ":: Blurred"
    fi
fi
cp $generatedversions/blur-$blur-$effect-$wallpaperfilename.png $blurredwallpaper

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
    touch $rasifile
fi
echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------

echo ":: Generate new cached wallpaper square-$wallpaperfilename"
magick $tmpwallpaper -gravity Center -extent 1:1 $squarewallpaper
cp $squarewallpaper $generatedversions/square-$wallpaperfilename.png

# ... (all other commands in wallpaper.sh, like reloading swaync, etc.) ...

# --- Add this block to call your logo theming script ---
# THEME_LOGO_SCRIPT_PATH="$HOME/.config/hypr/scripts/theme_fastfetch_logo.sh"
# if [ -f "$THEME_LOGO_SCRIPT_PATH" ]; then
#     bash "$THEME_LOGO_SCRIPT_PATH" &
# else
#     echo "Logo theming script not found: $THEME_LOGO_SCRIPT_PATH" >&2 # Kept warning, but made it less verbose
# fi
# --- End of added block ---

echo "Wallpaper script finished."
