#!/bin/bash
# ~/.config/waybar/scripts/get_wttr_temp.sh

CITY=""      # Leave blank for auto-IP location, or "YourCity", or "YourCity,YourCountryCode"
UNITS_PARAM="?u" # ?u for Imperial (Fahrenheit), ?m for Metric (Celsius)
                 # If you want Fahrenheit to get numbers like "95", use "?u"
                 # If you want Celsius, use "?m" (numbers will likely be lower, e.g., "35")

# Fetch only the temperature value using wttr.in's format option
# %t gives temperature with its unit, e.g., +78°F or +23°C
RAW_OUTPUT=$(curl -sf "wttr.in/${CITY}${UNITS_PARAM}&format=%t")

if [ -n "$RAW_OUTPUT" ]; then
    # Extract numbers, allow for negative sign, remove everything else
    TEMP_VALUE=$(echo "$RAW_OUTPUT" | sed 's/[^0-9\.-]//g' | awk '{printf "%.0f", $1}')

    if [ -n "$TEMP_VALUE" ]; then
        # Just the number and the degree symbol
        TEXT_OUTPUT="${TEMP_VALUE}°"
        
        # Create a more descriptive tooltip if desired
        TOOLTIP_TEXT="Temperature: ${TEMP_VALUE}°"
        if [[ "${UNITS_PARAM}" == "?u" ]]; then
            TOOLTIP_TEXT="${TOOLTIP_TEXT}F"
        elif [[ "${UNITS_PARAM}" == "?m" ]]; then
            TOOLTIP_TEXT="${TOOLTIP_TEXT}C"
        fi

        printf '{"text": "%s", "tooltip": "%s", "class": "weather-temp"}\n' "$TEXT_OUTPUT" "$TOOLTIP_TEXT"
    else
        printf '{"text": "N/A", "tooltip": "Temp value unavailable", "class": "weather-error"}\n'
    fi
else
    printf '{"text": "Err", "tooltip": "Failed to fetch wttr.in", "class": "weather-error"}\n'
fi