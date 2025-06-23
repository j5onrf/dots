# 🎨 Dynamic Theme Lock Feature

<img src="https://github.com/user-attachments/assets/20bb521d-d21c-479a-a6f1-fc516892f4b0" alt="Screenshot of the theme lock feature" width="75" align="left" style="margin-right: 20px;"/>

Ever find the perfect color theme for your Waybar and wish you could lock it in? That's exactly what the Theme-Lock feature is for. It allows you to keep your current color scheme even when you change wallpapers. A simple middle-click on the wallpaper icon enables or disables the dynamic theme generation, giving you full control.

This document explains the "Dynamic Theme Lock" feature, which allows you to temporarily prevent Matugen and Wallust from generating a new color theme when you change your wallpaper.

This is useful when you find a color scheme you love and want to keep it while exploring different background images.

 🚀 How to Use It

The feature is controlled by a simple mouse click on the **Wallpaper icon** (``) in your Waybar panel.

    **To DISABLE Dynamic Theming (Lock Current Theme):**
    *   **Middle-click** the wallpaper icon.
    *   A notification will appear saying: `Matugen Theming: DISABLED`.
    *   Now, when you change your wallpaper, your system's color theme will *not* change.

    **To RE-ENABLE Dynamic Theming:**
    *   **Middle-click** the wallpaper icon again.
    *   A notification will appear saying: `Matugen Theming: ENABLED`.
    *   The next time you change your wallpaper, the color theme will update dynamically as usual.

> **Note:** There is no change to the wallpaper icon itself. The notification is the primary indicator of the current state. This was a deliberate choice to keep the configuration simple and easy to share.

<br clear="all">

## 🔧 How It Works (Technical Details)

For those interested in the mechanism behind the feature, here is a brief overview:

1.  **The Toggle Script (`turn-off-matugen.sh`):**
    *   When you middle-click the Waybar icon, it executes the `~/.config/hypr/scripts/turn-off-matugen.sh` script.
    *   This script's only job is to create or delete a "lock file" located at `~/.config/ml4w/cache/matugen_lock`.

2.  **The Lock File:**
    *   If the lock file **exists**, theming is considered **DISABLED**.
    *   If the lock file **does not exist**, theming is considered **ENABLED**.

3.  **The Main Script (`wallpaper.sh`):**
    *   Before running `matugen` and `wallust`, the main `wallpaper.sh` script checks for the existence of the `matugen_lock` file.
    *   If it finds the lock file, it skips all color generation steps and prints a message to the console (`:: Matugen is locked.`).
    *   If the lock file is not found, it proceeds with generating and applying the new theme as normal.

## 📂 Relevant Files

*   **Toggle Script:** `~/.config/hypr/scripts/turn-off-matugen.sh`
*   **Main Wallpaper Script:** `~/wallpaper.sh` (or its full path)
*   **Waybar Configuration:** `~/.config/waybar/config` (or `config.jsonc`), where the `on-click-middle` action is defined for the `custom/wallpaper` module.
*   **The Lock File (Created at Runtime):** `~/.config/ml4w/cache/matugen_lock`
