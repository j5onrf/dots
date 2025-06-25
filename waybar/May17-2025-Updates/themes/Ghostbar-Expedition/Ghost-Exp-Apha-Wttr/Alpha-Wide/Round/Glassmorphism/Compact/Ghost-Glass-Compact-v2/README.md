*** Attention! You will need get_openweathermap_forecast.sh (Weather forecast - default) or get_openweathermap_temp.sh (simple temp)

![FullScreen-2025-06-23_09-31-40](https://github.com/user-attachments/assets/1a91025c-fb85-4908-8b5b-d022e0762515)

### Summary of Recent CSS Improvements

The overall goal of the recent changes in v2 was to **refactor** `Ghost-Glassmorphism (Compact)` stylesheet to make it cleaner, more consistent, and easier to maintain without changing the core functionality.

Here’s a breakdown of what was done:

1.  **Unified Corner Roundness (`border-radius`)**
    *   **What was changed:** Previously, different elements had different `border-radius` values (`0.2em`, `0.4em`). This was standardized to a single, consistent value of **`0.4em`** for all main modules and the tooltip, matching the main bar container.
    *   **Why:** This creates a more polished and visually consistent theme where all rounded corners look the same.

2.  **Consolidated Redundant Rules**
    *   **What was changed:** Several CSS rules were combined to reduce repetition.
        *   The separate styling blocks for `clock`, `weather`, and the `cpu`/`memory` modules were merged into a more logical group, as they all share the `SF Mono` font.
        *   A new group was created to handle all modules that are hidden by default (`#custom-appmenu`, `#custom-exit`, etc.).
    *   **Why:** This makes the stylesheet shorter, easier to read, and more maintainable. If you want to change a shared property in the future, you only need to edit it in one place.

The final result is a stylesheet that produces the same look as before but is better organized!

