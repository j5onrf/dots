#!/bin/bash
# ~/.config/hypr/scripts/get_wttr_temp.sh (Minimal: Temp display; Emoji + Feels Like in tooltip)

CITY=""      # Leave blank for auto-IP location, or "YourCity", or "YourCity,YourCountryCode"
UNITS_PARAM="?u" # ?u for Imperial (Fahrenheit), ?m for Metric (Celsius)
DISPLAY_UNIT_SHORT="F" # For display in tooltip parts

if [[ "${UNITS_PARAM}" == "?m" ]]; then
    DISPLAY_UNIT_SHORT="C"
fi

# Fetch only: Current Temperature (%t); Condition Emoji (%c); Feels Like Temp (%f)
FORMAT_STRING_FOR_DATA="%t;%c;%f"
RAW_DATA=$(curl -sf "wttr.in/${CITY}${UNITS_PARAM}&format=${FORMAT_STRING_FOR_DATA}")

# Initialize defaults
CURRENT_TEMP_FOR_DISPLAY="N/A"
TOOLTIP_STRING="Weather data unavailable"

if [ -n "$RAW_DATA" ]; then
    # Use cut to parse the semicolon-delimited string
    CURRENT_TEMP_RAW=$(echo "$RAW_DATA" | cut -d';' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    CONDITION_EMOJI=$(echo "$RAW_DATA"  | cut -d';' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    FEELS_LIKE_RAW=$(echo "$RAW_DATA"   | cut -d';' -f3 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Clean up temperature values
    CURRENT_TEMP_VALUE=$(echo "$CURRENT_TEMP_RAW" | sed 's/[^0-9\.-]//g' | awk '{printf "%.0f", $1}')
    FEELS_LIKE_VALUE=$(echo "$FEELS_LIKE_RAW" | sed 's/[^0-9\.-]//g' | awk '{printf "%.0f", $1}')

    if [ -n "$CURRENT_TEMP_VALUE" ]; then
        CURRENT_TEMP_FOR_DISPLAY="${CURRENT_TEMP_VALUE}°" # Main display text
        
        TOOLTIP_PARTS=()
        
        # Condition Emoji (if available)
        [[ -n "$CONDITION_EMOJI" ]] && TOOLTIP_PARTS+=("$CONDITION_EMOJI")

        # Feels Like (if available)
        [[ -n "$FEELS_LIKE_VALUE" ]] && TOOLTIP_PARTS+=("Feels like: ${FEELS_LIKE_VALUE}°${DISPLAY_UNIT_SHORT}")
        
        # Construct the tooltip string
        TEMP_TOOLTIP_STRING=""
        for i in "${!TOOLTIP_PARTS[@]}"; do
            TEMP_TOOLTIP_STRING+="${TOOLTIP_PARTS[$i]}"
            # Add a separator like " | " or a few spaces if you want them on the same line,
            # or \n if you want them on separate lines (and Waybar tooltip supports it).
            # For minimal tooltip that might fit on one line:
            if [[ $i -lt $((${#TOOLTIP_PARTS[@]} - 1)) ]]; then
                TEMP_TOOLTIP_STRING+="  " # Separator for single-line tooltip
            fi
        done
        
        if [[ -n "$TEMP_TOOLTIP_STRING" ]]; then
            TOOLTIP_STRING="$TEMP_TOOLTIP_STRING"
        else # Fallback if all optional tooltip parts were empty
             TOOLTIP_STRING="Current: ${CURRENT_TEMP_VALUE}°${DISPLAY_UNIT_SHORT}"
        fi
    else
        CURRENT_TEMP_FOR_DISPLAY="N/A"
        TOOLTIP_STRING="Temperature unavailable"
    fi
else
    CURRENT_TEMP_FOR_DISPLAY="Err"
    TOOLTIP_STRING="Failed to fetch weather"
fi

# Escape double quotes within the tooltip string for JSON validity
# Newlines are not explicitly added to TEMP_TOOLTIP_STRING anymore unless you change the separator above.
ESCAPED_TOOLTIP_STRING=$(echo "$TOOLTIP_STRING" | sed 's/"/\\"/g')

printf '{"text": "%s", "tooltip": "%s", "class": "weather-temp"}\n' "$CURRENT_TEMP_FOR_DISPLAY" "$ESCAPED_TOOLTIP_STRING"

    