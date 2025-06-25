#!/bin/bash
# ~/.config/hypr/scripts/get_openweathermap_temp.sh

# --- CONFIGURATION ---
API_KEY="YOUR_API_KEY_HERE" # <<< IMPORTANT: PUT YOUR KEY HERE
UNITS="imperial"              # "metric" for Celsius, "imperial" for Fahrenheit

# --- LOCATION SETTINGS ---
# Set your location. Using a City ID is the most reliable method.
# To find your City ID:
# 1. Go to openweathermap.org
# 2. Search for your city.
# 3. The URL will be something like: openweathermap.org/city/0000000
# 4. The number at the end (0000000) is your City ID.

# Examples:
# LOCATION="0000000"         (City ID for xyz, MO, USA)
# LOCATION="xyz,US,MO"  (City, Country, State)
# LOCATION="00000,us"        (ZIP Code)
# LOCATION="lat=38.40&lon=-20.43" (Latitude & Longitude)
LOCATION="0000000"

# When you MUST override "auto":
#   In the very rare case that your city's actual NAME consists only of numbers
#   (e.g., the town of "1770" in Australia). In this situation, 'auto' would mistake
#   the name for a City ID. You would then have to set QUERY_TYPE="q" to force a name search.
QUERY_TYPE="auto"


# --- SCRIPT LOGIC (No need to edit below) ---
if [[ "$UNITS" == "metric" ]]; then
    DISPLAY_UNIT_SHORT="C"
else
    DISPLAY_UNIT_SHORT="F"
fi

# Determine the correct API parameter based on QUERY_TYPE
API_PARAM=""
if [[ "$QUERY_TYPE" == "auto" ]]; then
    if [[ $LOCATION =~ ^[0-9]+$ ]]; then
        QUERY_TYPE="id" # It's a number, assume it's a City ID
    elif [[ $LOCATION == *"lat="* && $LOCATION == *"lon="* ]]; then
        QUERY_TYPE="coords" # It contains lat= and lon=
    else
        QUERY_TYPE="q" # Default to city name query
    fi
fi

case "$QUERY_TYPE" in
    "id")     API_PARAM="id=${LOCATION}" ;;
    "q")      API_PARAM="q=${LOCATION}" ;;
    "zip")    API_PARAM="zip=${LOCATION}" ;;
    "coords") API_PARAM="${LOCATION}" ;;
    *)        API_PARAM="q=${LOCATION}" ;; # Fallback
esac

# Construct the final API URL
API_URL="http://api.openweathermap.org/data/2.5/weather?${API_PARAM}&appid=${API_KEY}&units=${UNITS}"

RAW_DATA=$(curl -sf "$API_URL")

# --- PARSING AND OUTPUT ---
if [ -z "$RAW_DATA" ]; then
    printf '{"text": "ERR", "tooltip": "Failed to fetch weather data."}\n'
    exit 1
fi

if [ "$(echo "$RAW_DATA" | jq -r '.cod')" != "200" ]; then
    ERROR_MESSAGE=$(echo "$RAW_DATA" | jq -r '.message // "Unknown API error"')
    printf '{"text": "API?", "tooltip": "API Error: %s"}\n' "$ERROR_MESSAGE"
    exit 1
fi

CURRENT_TEMP=$(echo "$RAW_DATA" | jq '.main.temp' | awk '{printf "%.0f°", $1}')
FEELS_LIKE=$(echo "$RAW_DATA" | jq '.main.feels_like' | awk '{printf "%.0f°", $1}')
CONDITION_TEXT=$(echo "$RAW_DATA" | jq -r '.weather[0].description' | sed -e "s/\b\(.\)/\u\1/g")
ICON_ID=$(echo "$RAW_DATA" | jq -r '.weather[0].id')

case "$ICON_ID" in
    800) EMOJI="☀️";; 801) EMOJI="🌤️";; 802) EMOJI="⛅";; 803|804) EMOJI="☁️";;
    5*) EMOJI="🌧️";;  2*) EMOJI="⛈️";;  6*) EMOJI="❄️";;  7*) EMOJI="🌫️";;
    *)  EMOJI="";;
esac

TOOLTIP="$CONDITION_TEXT $EMOJI  Feels Like: $FEELS_LIKE"

printf '{"text": "%s", "tooltip": "%s", "class": "weather-temp-owm"}\n' "$CURRENT_TEMP" "$TOOLTIP"
