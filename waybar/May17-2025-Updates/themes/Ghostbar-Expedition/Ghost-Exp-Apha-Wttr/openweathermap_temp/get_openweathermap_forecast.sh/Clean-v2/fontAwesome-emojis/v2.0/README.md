```markdown
# Waybar Weather & Forecast Script

  
*Replace the image URL above with a screenshot of your actual Waybar module.*

A robust and feature-rich script for displaying current weather and a 5-day forecast in Waybar. It is optimized for performance, highly configurable, and provides dynamic, at-a-glance status indicators through color changes.

---

## Features

-   **Current Weather Display**: Shows the current temperature.
-   **5-Day Forecast Tooltip**: Hover to see a detailed forecast for the next five days.
-   **Dynamic Color States**: Automatically changes text color based on user-defined "hot" and "cold" temperature thresholds, with a neutral default color for normal conditions.
-   **"Feels Like" Temperature**: The tooltip provides the "feels like" temperature for a more accurate sense of conditions.
-   **FontAwesome Icons**: Uses modern FontAwesome Pro icons for clear and stylish weather condition display.
-   **Robust Caching**: Caches API results to prevent rate-limiting and reduce unnecessary network calls, speeding up response time.
-   **Self-Healing Data**: Automatically re-fetches data if the cache is stale or corrupted.
-   **Performance Optimized**: Uses efficient shell scripting techniques and a single `jq` call to minimize CPU usage and process calls.

---

## Installation

1.  **Dependencies**: Ensure you have the following installed on your system:
    -   `jq` (for parsing JSON)
    -   `curl` (for fetching data)
    -   A **Nerd Font** or a font that includes **FontAwesome Pro** icons to correctly display the weather emojis.

2.  **Download the Script**: Place the `weather.sh` script (or whatever you name it) into your Waybar scripts directory. A common location is `~/.config/waybar/scripts/`.

3.  **Make it Executable**: Open a terminal and run:
    ```bash
    chmod +x ~/.config/waybar/scripts/weather.sh
    ```

---

## Configuration

### 1. Script Configuration

You must edit the top section of the `weather.sh` script to add your personal details.

```bash
# --- CONFIGURATION ---
# You MUST configure these settings to use the script.

# 1. API_KEY: Get your free API key from https://openweathermap.org/
API_KEY="YOUR_API_KEY_HERE"

# 2. LOCATION_QUERY: Find your City ID on the OpenWeatherMap website.
#    (e.g., https://openweathermap.org/city/5128581 -> New York City ID is 5128581)
LOCATION_QUERY="YOUR_CITY_ID_HERE"

# 3. UNITS: "metric" for Celsius, "imperial" for Fahrenheit.
UNITS="imperial"

# 4. TEMPERATURE THRESHOLDS: Set your personal definitions for hot and cold.
#    Based on the UNITS setting above (Fahrenheit in this example).
HOT_THRESHOLD=92
COLD_THRESHOLD=20
```

### 2. Waybar `config`

Add the following module block to your `~/.config/waybar/config` file:

```json
"custom/weather": {
    "format": "{}",
    "tooltip": true,
    "interval": 3600, // Refresh every hour
    "exec": "~/.config/waybar/scripts/weather.sh",
    "return-type": "json"
},
```

### 3. Waybar `style.css`

Add the following rules to your `~/.config/waybar/style.css` to enable the dynamic colors. You can use hardcoded hex values or theme variables (like from `matugen`).

```css
/* --- Weather Temperature Styles --- */
/*
 * The module's CSS ID is #custom-weather.
 * You can also use #weather if you add `"name": "weather"` to your config block.
*/

#custom-weather.hot {
    /* Red for hot temperatures. Use a theme variable or a specific hex code. */
    color: #bf616a; /* Example: Nord Red */
}

#custom-weather.cold {
    /* Blue for cold temperatures. Use a theme variable or a specific hex code. */
    color: #88c0d0; /* Example: Nord Frost Blue */
}

/* Note: No rule is needed for the "normal" state. It will use the default text color. */
```

### 4. (Optional) Refresh on Resume from Suspend

To ensure the weather updates after your computer wakes from sleep, create a systemd service.

Create the file `/etc/systemd/system/waybar-resume.service` with `sudo`:

```ini
[Unit]
Description=Refresh Waybar on resume for user <your_username>
After=suspend.target hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
User=<your_username>
ExecStart=/usr/bin/pkill -SIGRTMIN+1 waybar

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target
```

**Important**:
-   Replace `<your_username>` with your actual Linux username.
-   The signal `SIGRTMIN+1` targets the first `custom/...` module. If your weather module is not the first one, adjust the number accordingly (e.g., `SIGRTMIN+8`). You may also need to add a `"signal"` property to your module in the Waybar `config`.

Then, enable the service with `sudo`:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now waybar-resume.service
```

---

## Acknowledgements

-   **OpenWeatherMap** for providing the free weather data API.
-   **FontAwesome** for the high-quality icons.
-   The **Waybar** project for creating a fantastic and customizable status bar.
```
