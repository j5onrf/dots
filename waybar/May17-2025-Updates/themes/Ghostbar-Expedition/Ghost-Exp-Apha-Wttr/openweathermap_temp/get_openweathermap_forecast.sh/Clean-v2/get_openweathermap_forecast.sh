#!/bin/bash
# ~/.config/hypr/scripts/get_openweathermap_forecast.sh

# --- CONFIGURATION ---
API_KEY="" # <<< YOUR API KEY
LOCATION_QUERY="xyz,US,MO"    # Example: q=City,Country,State or lat=LAT&lon=LON
UNITS="imperial"              # "metric" for Celsius, "imperial" for Fahrenheit

# --- SCRIPT LOGIC ---
API_URL="http://api.openweathermap.org/data/2.5/forecast?q=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
CACHE_FILE="/tmp/waybar_weather_cache.json"
CACHE_TTL=1800

if ! [ -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_TTL ]; then
    curl -sf "$API_URL" > "$CACHE_FILE"
fi

if [ ! -s "$CACHE_FILE" ]; then
    printf '{"text": "ERR", "tooltip": "Weather data fetch failed."}\n'
    exit 1
fi

RAW_DATA=$(cat "$CACHE_FILE")

if [ "$(echo "$RAW_DATA" | jq -r '.cod')" != "200" ]; then
    ERROR_MESSAGE=$(echo "$RAW_DATA" | jq -r '.message')
    printf '{"text": "API?", "tooltip": "API Error: %s"}\n' "$ERROR_MESSAGE"
    exit 1
fi

# --- PARSE CURRENT WEATHER ---
CURRENT_TEMP=$(echo "$RAW_DATA" | jq '.list[0].main.temp' | awk '{printf "%.0f°", $1}')
FEELS_LIKE_TEMP=$(echo "$RAW_DATA" | jq '.list[0].main.feels_like' | awk '{printf "%.0f°", $1}')
CURRENT_ICON_CODE=$(echo "$RAW_DATA" | jq -r '.list[0].weather[0].id')
# MODIFIED: Added parsing for the text description for the new tooltip format
CURRENT_CONDITION_TEXT=$(echo "$RAW_DATA" | jq -r '.list[0].weather[0].description' | sed -e "s/\b\(.\)/\u\1/g")

# Function to map weather ID to an emoji
get_emoji() {
    local code=$1
    case "$code" in
        800) echo "☀️";; 801) echo "🌤️";; 802) echo "⛅";; 803|804) echo "☁️";;
        5*) echo "🌧️";;  2*) echo "⛈️";;  6*) echo "❄️";;  7*) echo "🌫️";;
        *)  echo "";;
    esac
}

CURRENT_EMOJI=$(get_emoji $CURRENT_ICON_CODE)

# --- PARSE 5-DAY FORECAST ---
FORECAST_DATA=$(echo "$RAW_DATA" | jq -r '
    .list | group_by(.dt_txt | .[:10]) | .[0:5] |
    map(
        {
            day: (.[0].dt_txt | strptime("%Y-%m-%d %H:%M:%S") | strftime("%a")),
            min: (map(.main.temp_min) | min | round),
            max: (map(.main.temp_max) | max | round),
            id: (.[4].weather[0].id // .[0].weather[0].id)
        } | "\(.day):\(.min):\(.max):\(.id)"
    ) | .[]
')

TOOLTIP_BODY=""
while IFS= read -r line; do
    IFS=':' read -r day min max id <<< "$line"
    forecast_emoji=$(get_emoji $id)
    TOOLTIP_BODY+="${forecast_emoji} ${day} ${min}° ${max}°\n"
done <<< "$FORECAST_DATA"

TOOLTIP_BODY=$(echo -e "${TOOLTIP_BODY%\\n}")

TEXT_OUTPUT="$CURRENT_TEMP"

CONDITION_LINE="$CURRENT_CONDITION_TEXT $CURRENT_EMOJI"
FEELS_LIKE_LINE="Feels Like: $FEELS_LIKE_TEMP"
TOOLTIP_TITLE="5-Day Forecast"
FULL_TOOLTIP="$CONDITION_LINE\n$FEELS_LIKE_LINE\n\n$TOOLTIP_TITLE\n$TOOLTIP_BODY"

# Escape newlines in the tooltip for valid JSON output for Waybar.
printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"