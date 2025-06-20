#!/bin/bash
# ~/.config/hypr/scripts/get_wttr_temp.sh (Minimal Tooltip)

CITY=""
UNITS_PARAM="?u" # ?u for Imperial (Fahrenheit), ?m for Metric (Celsius)
DISPLAY_UNIT_SHORT="F" # For display in tooltip parts if needed (e.g. Feels Like)

if [[ "${UNITS_PARAM}" == "?m" ]]; then
    DISPLAY_UNIT_SHORT="C"
fi

# Fetch data: Location, Current Temp (for display), Condition, Emoji, Feels Like, Humidity
# We still fetch current temp (%t) to get the value for CURRENT_TEMP_FOR_DISPLAY
FORMAT_STRING_FOR_DATA="%l;%t;%C;%c;%f;%h" # Removed Wind (%w) for more minimalism, can add back if desired
RAW_DATA=$(curl -sf "wttr.in/${CITY}${UNITS_PARAM}&format=${FORMAT_STRING_FOR_DATA}")

CURRENT_TEMP_FOR_DISPLAY="N/A"
TOOLTIP_STRING="Weather data unavailable"

if [ -n "$RAW_DATA" ]; then
    LOCATION=$(echo "$RAW_DATA"       | cut -d';' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    CURRENT_TEMP_RAW=$(echo "$RAW_DATA" | cut -d';' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    CONDITION_TEXT=$(echo "$RAW_DATA"   | cut -d';' -f3 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    CONDITION_EMOJI=$(echo "$RAW_DATA"  | cut -d';' -f4 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    FEELS_LIKE_RAW=$(echo "$RAW_DATA"   | cut -d';' -f5 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    HUMIDITY=$(echo "$RAW_DATA"       | cut -d';' -f6 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    CURRENT_TEMP_VALUE=$(echo "$CURRENT_TEMP_RAW" | sed 's/[^0-9\.-]//g' | awk '{printf "%.0f", $1}')
    FEELS_LIKE_VALUE=$(echo "$FEELS_LIKE_RAW" | sed 's/[^0-9\.-]//g' | awk '{printf "%.0f", $1}')

    if [ -n "$CURRENT_TEMP_VALUE" ]; then
        CURRENT_TEMP_FOR_DISPLAY="${CURRENT_TEMP_VALUE}°" # Main display text
        
        TOOLTIP_PARTS=()
        # Location (optional, can be long)
        # [[ -n "$LOCATION" && "$LOCATION" != "Location not found" && "$LOCATION" != *"language switcher"* ]] && TOOLTIP_PARTS+=("$LOCATION")
        
        # Condition (Text + Emoji)
        CONDITION_DISPLAY=""
        if [[ -n "$CONDITION_TEXT" ]]; then CONDITION_DISPLAY+="$CONDITION_TEXT"; fi
        if [[ -n "$CONDITION_EMOJI" ]]; then CONDITION_DISPLAY+=" $CONDITION_EMOJI"; fi
        CONDITION_DISPLAY_TRIMMED=$(echo "$CONDITION_DISPLAY" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -n "$CONDITION_DISPLAY_TRIMMED" ]] && TOOLTIP_PARTS+=("$CONDITION_DISPLAY_TRIMMED") # Show condition first

        # Feels Like
        [[ -n "$FEELS_LIKE_VALUE" ]] && TOOLTIP_PARTS+=("Feels like: ${FEELS_LIKE_VALUE}°${DISPLAY_UNIT_SHORT}")
        
        # Humidity
        [[ -n "$HUMIDITY" ]] && TOOLTIP_PARTS+=("Humidity: $HUMIDITY")
        
        # Add other minimal things you want, e.g., Sunrise/Sunset if fetched
        # [[ -n "$SUNRISE_TIME" ]] && TOOLTIP_PARTS+=("Sunrise: $SUNRISE_TIME")

        TEMP_TOOLTIP_STRING=""
        for i in "${!TOOLTIP_PARTS[@]}"; do
            TEMP_TOOLTIP_STRING+="${TOOLTIP_PARTS[$i]}"
            if [[ $i -lt $((${#TOOLTIP_PARTS[@]} - 1)) ]]; then
                TEMP_TOOLTIP_STRING+=$'\n' 
            fi
        done
        
        if [[ -n "$TEMP_TOOLTIP_STRING" ]]; then
            TOOLTIP_STRING="$TEMP_TOOLTIP_STRING"
        else # Fallback if all optional tooltip parts were empty
             TOOLTIP_STRING="Current: ${CURRENT_TEMP_VALUE}°${DISPLAY_UNIT_SHORT}" # Very minimal fallback
        fi
    else
        CURRENT_TEMP_FOR_DISPLAY="N/A"
        TOOLTIP_STRING="Temperature unavailable"
    fi
else
    CURRENT_TEMP_FOR_DISPLAY="Err"
    TOOLTIP_STRING="Failed to fetch weather"
fi

ESCAPED_TOOLTIP_STRING=$(echo "$TOOLTIP_STRING" | sed 's/"/\\"/g' | sed ":a;N;\$!ba;s/\n/\\\\n/g")

printf '{"text": "%s", "tooltip": "%s", "class": "weather-temp"}\n' "$CURRENT_TEMP_FOR_DISPLAY" "$ESCAPED_TOOLTIP_STRING"

    