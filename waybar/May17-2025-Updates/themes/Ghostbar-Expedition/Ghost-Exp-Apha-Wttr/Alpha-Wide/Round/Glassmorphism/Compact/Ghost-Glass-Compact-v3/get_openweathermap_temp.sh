#!/bin/bash
# ~/.config/hypr/scripts/get_openweathermap_temp.sh

API_KEY="x" # <<< PUT YOUR ACTUAL API KEY HERE
LOCATION_QUERY="x,US,MO" # Example: City,CountryCode,StateCode (for US)
                             # Or: "q=London,UK"
                             # Or: "id=YOUR_CITY_ID"
                             # Or: "lat=YOUR_LAT&lon=YOUR_LON"

UNITS="imperial" # "metric" for Celsius, "imperial" for Fahrenheit
DISPLAY_UNIT_SHORT="F"
if [[ "$UNITS" == "metric" ]]; then
    DISPLAY_UNIT_SHORT="C"
fi

# Construct the API URL
API_URL="http://api.openweathermap.org/data/2.5/weather?q=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
# If using City ID: API_URL="http://api.openweathermap.org/data/2.5/weather?id=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
# If using Lat/Lon: API_URL="http://api.openweathermap.org/data/2.5/weather?lat=LAT_VAL&lon=LON_VAL&appid=${API_KEY}&units=${UNITS}"


RAW_DATA=$(curl -sf "$API_URL")

# Initialize defaults
CURRENT_TEMP_FOR_DISPLAY="N/A"
TOOLTIP_STRING="Weather data unavailable"

if [ -n "$RAW_DATA" ] && [ "$(echo "$RAW_DATA" | jq -r '.cod')" == "200" ]; then
    # Check if 'main' and 'temp' fields exist
    if echo "$RAW_DATA" | jq -e '.main.temp' > /dev/null; then
        CURRENT_TEMP_VALUE=$(echo "$RAW_DATA" | jq '.main.temp' | awk '{printf "%.0f", $1}')
        CURRENT_TEMP_FOR_DISPLAY="${CURRENT_TEMP_VALUE}°"

        # For Tooltip (Condition Emoji and Feels Like)
        FEELS_LIKE_VALUE=""
        if echo "$RAW_DATA" | jq -e '.main.feels_like' > /dev/null; then
            FEELS_LIKE_VALUE=$(echo "$RAW_DATA" | jq '.main.feels_like' | awk '{printf "%.0f", $1}')
        fi

        CONDITION_EMOJI=""
        # OpenWeatherMap provides an icon code, not a direct emoji.
        # You'd need a mapping or use a different field like 'description'.
        # For simplicity, let's use the description for now.
        CONDITION_TEXT=""
        if echo "$RAW_DATA" | jq -e '.weather[0].description' > /dev/null; then
             CONDITION_TEXT=$(echo "$RAW_DATA" | jq -r '.weather[0].description' | sed -e "s/\b\(.\)/\u\1/g") # Capitalize first letter of each word
        fi
        # You could add a function here to map weather[0].id or weather[0].icon to an emoji
        # Example of a very simple mapping (expand this greatly):
        ICON_ID=$(echo "$RAW_DATA" | jq -r '.weather[0].id')
        case "$ICON_ID" in
            800) CONDITION_EMOJI="☀️";; # Clear
            801) CONDITION_EMOJI="🌤️";; # Few clouds
            802) CONDITION_EMOJI="⛅";; # Scattered clouds
            803) CONDITION_EMOJI="🌥️";; # Broken clouds
            804) CONDITION_EMOJI="☁️";; # Overcast clouds
            5*) CONDITION_EMOJI="🌧️";;  # Rain (all 5xx codes)
            2*) CONDITION_EMOJI="⛈️";;  # Thunderstorm (all 2xx codes)
            6*) CONDITION_EMOJI="❄️";;  # Snow (all 6xx codes)
            7*) CONDITION_EMOJI="🌫️";;  # Atmosphere (fog, mist etc. - all 7xx codes)
            *)  CONDITION_EMOJI="";;   # Default if no match
        esac


        TOOLTIP_PARTS=()
        [[ -n "$CONDITION_TEXT" || -n "$CONDITION_EMOJI" ]] && TOOLTIP_PARTS+=("$(echo "${CONDITION_TEXT}${CONDITION_EMOJI}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')")
        [[ -n "$FEELS_LIKE_VALUE" ]] && TOOLTIP_PARTS+=("Feels like: ${FEELS_LIKE_VALUE}°${DISPLAY_UNIT_SHORT}")
        
        TEMP_TOOLTIP_STRING=""
        for i in "${!TOOLTIP_PARTS[@]}"; do
            TEMP_TOOLTIP_STRING+="${TOOLTIP_PARTS[$i]}"
            if [[ $i -lt $((${#TOOLTIP_PARTS[@]} - 1)) ]]; then
                TEMP_TOOLTIP_STRING+="  " # Using " | " as a separator for a more compact tooltip
            fi
        done
        
        if [[ -n "$TEMP_TOOLTIP_STRING" ]]; then
            TOOLTIP_STRING="$TEMP_TOOLTIP_STRING"
        else
             TOOLTIP_STRING="Current: ${CURRENT_TEMP_VALUE}°${DISPLAY_UNIT_SHORT}"
        fi
    else
        CURRENT_TEMP_FOR_DISPLAY="N/A" # If .main.temp is missing
        TOOLTIP_STRING="Temp data format error"
    fi
elif [ -n "$RAW_DATA" ]; then # API returned data, but not success code 200
    ERROR_MESSAGE=$(echo "$RAW_DATA" | jq -r '.message // "Unknown API error"')
    CURRENT_TEMP_FOR_DISPLAY="API?"
    TOOLTIP_STRING="API Error: $ERROR_MESSAGE"
else
    CURRENT_TEMP_FOR_DISPLAY="Err"
    TOOLTIP_STRING="Failed to fetch OpenWeatherMap"
fi

ESCAPED_TOOLTIP_STRING=$(echo "$TOOLTIP_STRING" | sed 's/"/\\"/g')
printf '{"text": "%s", "tooltip": "%s", "class": "weather-temp-owm"}\n' "$CURRENT_TEMP_FOR_DISPLAY" "$ESCAPED_TOOLTIP_STRING"

    
