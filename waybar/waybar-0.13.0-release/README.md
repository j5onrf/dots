---

### Waybar v0.13.0: Regression in `hyprland/workspaces` Dynamic Icon Updates

#### Summary (TL;DR)

After upgrading from Waybar `v0.12.0` to `v0.13.0`, the `hyprland/workspaces` module no longer dynamically updates window icons based on `windowtitle` changes (e.g., switching browser tabs). The icon now remains static for the first-detected window on a workspace and only updates upon a full Waybar reload. The current solution is to downgrade to `v0.12.0` and lock the version.

---

#### The Problem: Loss of Dynamic Behavior

In Waybar `v0.12.0` and earlier, the following configuration allowed for a single, dynamic icon on each workspace that would update instantly based on the focused window's `class` or `title`. This was particularly useful for seeing the icon of the active browser tab.

**Working Configuration (on Waybar v0.12.0):**
```json
"hyprland/workspaces#rw": {
    "format": "{icon}{windows}",
    "format-window-separator": "\n", // Ensures vertical icon visibility
    "window-rewrite": {
        "title<.*youtube.*>": "\uf04b",
        "class<firefox>": "\ue24f"
        // ... more rules
    }
}
```
This provided a clean, single-module solution for both workspace navigation and active window identification.

Upon upgrading to Waybar `v0.13.0`, this behavior is broken. The icon displayed by `{windows}` becomes static. It represents the first window Waybar detects on the workspace and **does not change** when switching focus to another window or tab on the same workspace.

#### Root Cause Analysis: A Change in Event Handling

The breakage is due to a change in the event-handling logic within the `hyprland/workspaces` module between versions.

1.  **Previous Behavior (v0.12.0):** The `hyprland/workspaces` module was likely either subscribing to Hyprland's `windowtitle` change events or was receiving a window list that was sorted with the active window first. This allowed the `{windows}` formatter to seemingly react to focus changes, even though this was likely an unintended side effect rather than a designed feature.

2.  **Current Behavior (v0.13.0):** The module's logic has been refactored. It appears to have been optimized to **no longer subscribe to `windowtitle` events**. It now only reacts to more significant workspace events like `openwindow`, `closewindow`, and `movewindow`. This is a deliberate design choice to improve performance and enforce a clearer separation of concerns, where title monitoring is now the exclusive responsibility of the `hyprland/window` module.

The impact of this change is that configurations relying on the old, unintentional behavior are no longer viable.

#### Current Solution and Justification

To preserve the original, single-module configuration and its aesthetic, the most direct solution is to revert to a known-working version.

1.  **Downgrade Waybar:** Revert the package from `v0.13.0` to `v0.12.0`. On Arch Linux, this can be done via the pacman cache:
    ```bash
    sudo pacman -U /var/cache/pacman/pkg/waybar-0.12.0-1-x86_64.pkg.tar.zst
    ```

2.  **Lock the Version:** Prevent the package from being upgraded during routine system updates by adding it to the `IgnorePkg` list in `/etc/pacman.conf`.
    ```
    IgnorePkg = waybar
    ```

This ensures the restoration of critical functionality until a future version of Waybar either re-introduces this behavior or a decision is made to adopt another bar and/or configuration.
