![2025-06-22T19:30:03,668139783-05:00](https://github.com/user-attachments/assets/0567e0f2-242f-428a-b4d9-2394199aa878)

Of course. A good README is essential for a shared project. This document explains the feature, its purpose, and how to use it clearly and concisely.

Here is a ready-to-use `README.md` file. You can save this directly into the root of your project directory.

---

```md
# 🎨 Dynamic Theme Lock Feature

This document explains the "Dynamic Theme Lock" feature, which allows you to temporarily prevent Matugen and Wallust from generating a new color theme when you change your wallpaper.

This is useful when you find a color scheme you love and want to keep it while exploring different background images.

## 🚀 How to Use It

The feature is controlled by a simple mouse click on the **Wallpaper icon** (``) in your Waybar panel.

*   **To DISABLE Dynamic Theming (Lock Current Theme):**
    *   **Middle-click** the wallpaper icon.
    *   A notification will appear saying: `Matugen Theming: DISABLED`.
    *   Now, when you change your wallpaper, your system's color theme will *not* change.

*   **To RE-ENABLE Dynamic Theming:**
    *   **Middle-click** the wallpaper icon again.
    *   A notification will appear saying: `Matugen Theming: ENABLED`.
    *   The next time you change your wallpaper, the color theme will update dynamically as usual.

> **Note:** There is no change to the wallpaper icon itself. The notification is the primary indicator of the current state. This was a deliberate choice to keep the configuration simple and easy to share.

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
```
