# Waybar 0.13.0 Release

Based on the official 0.13.0 release notes, here's a breakdown of why you would want to upgrade. While it doesn't introduce a revolutionary new set of CSS properties, it offers significant improvements to **layout, behavior, and stability**, especially for features you're already using.

### No, There Are Not "New CSS Features"

To answer your main question directly: No, Waybar 0.13.0 does not appear to add brand-new CSS properties or drastically change the GTK CSS parser. The core styling engine remains the same.

However, the reasons to upgrade are still very compelling.

### Yes, There Are New Features That Directly Affect Your Theme

The most exciting changes are new configuration options that give you more control over the layout and behavior, which you would otherwise have to try and hack together with CSS.

#### 1. Module Stretching and Center Module Toggling

This is the biggest new visual feature. You can now make modules expand to fill available space and even hide the center module until you hover over the bar.
*   **`"stretch": true`**: Add this to a module (like the `workspaces` module) to make it fill all available space in its container (`.modules-left`, etc.).
*   **`"modules-center-on-hover": true`**: Add this at the top level of your config. It will make your entire `.modules-center` block invisible by default and only reveal it when you move your mouse over the Waybar window.

#### 2. Bug Fixes for Features You Use

This is arguably the most important reason for you to upgrade. The release notes mention several fixes that directly address things we've discussed:
*   **Drawer/Group Fix:** There is a specific fix for a "group revealer hover regression." This means the drawer pop-ups you use for your settings and hardware groups should be **more stable and reliable**. This alone could be worth the upgrade.
*   **Hyprland Fixes:** There are several fixes related to how Waybar interacts with Hyprland, including how it handles window titles and workspace states, which could lead to a more stable experience.

#### 3. New Options for Existing Modules

Many individual modules got small but useful quality-of-life updates. For example:
*   **`cava` module:** Now has CSS triggers and a `format-silent` option.
*   **`temperature` module:** Now has a `warning` threshold.
*   **`backlight` module:** Added a `minimum` brightness option.

### Verdict: Should You Upgrade to Waybar 13?

**Yes, absolutely.**

While you won't get a new toolbox of CSS properties, you will get:
1.  **More Stability:** Crucial bug fixes for the `group` drawers and Hyprland integration mean a smoother, more reliable bar.
2.  **Better Layout Control:** The new `stretch` and `modules-center-on-hover` options give you powerful new ways to design your bar's layout directly from the config.
3.  **A More Polished Experience:** The collection of small fixes and module updates will result in a better overall user experience.

The upgrade is less about adding new styling commands and more about making the existing foundation more powerful and stable.
