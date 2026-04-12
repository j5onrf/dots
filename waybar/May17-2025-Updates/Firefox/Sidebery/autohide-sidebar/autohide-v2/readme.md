# Instant & Delayed Autohide for Firefox Sidebery

This `userChrome.css` snippet provides a clean, highly functional, and responsive autohiding sidebar for Firefox, designed to work perfectly with the Sidebery extension.

It solves the common problem of accidental sidebar closures, especially for users with gaps between windows (e.g., in a tiling window manager).

## Features

*   **Hides Default UI:** Collapses the native Firefox tab bar and the sidebar header for a minimal look.
*   **Delayed Autohide:** The sidebar remains open until you move your mouse away for a set duration (e.g., 10 seconds), preventing accidental closing.
*   **Instant Transitions:** The sidebar snaps open and closed instantly, with no animations or visual delay.
*   **Hover-to-Open:** The sidebar collapses to a narrow, nearly-invisible strip at the edge of the window. Hovering over this strip instantly re-opens the sidebar.
*   **Easy to Customize:** Key variables like sidebar width and the autohide delay can be easily changed at the top of the file.

## Installation

1.  **Enable `userChrome.css`:**
    *   Type `about:config` in your Firefox address bar.
    *   Search for `toolkit.legacyUserProfileCustomizations.stylesheets`.
    *   Set the value to `true`.

2.  **Find Your Profile Folder:**
    *   Type `about:support` in your Firefox address bar.
    *   Look for the "Profile Folder" entry and click the "Open Directory" button.

3.  **Create the File:**
    *   Inside your profile folder, create a new folder named `chrome`.
    *   Inside the `chrome` folder, create a new file named `userChrome.css`.

4.  **Add the Code:**
    *   Copy the code from the `userChrome.css` file in this repository and paste it into the file you just created.

5.  **Restart Firefox:**
    *   Close and reopen Firefox completely to apply the changes.

## Customization

You can easily tweak the sidebar's behavior by editing the variables in the `:root` section at the top of the `userChrome.css` file:

```css
:root {
  /* --- CUSTOMIZE THESE VALUES --- */
  --uc-sidebar-expanded-width: 280px; /* The width of the sidebar when open */
  --uc-sidebar-collapsed-width: 5px;  /* The width when hidden */
  --uc-autohide-delay: 10s;           /* The delay before hiding */
  /* --- END OF CUSTOMIZATION --- */
}
```

