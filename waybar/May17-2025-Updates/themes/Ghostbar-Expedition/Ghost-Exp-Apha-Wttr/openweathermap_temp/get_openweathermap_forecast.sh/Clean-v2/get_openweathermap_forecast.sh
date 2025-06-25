#!/bin/bash
# ~/.config/hypr/scripts/get_openweathermap_forecast.sh

# --- CONFIGURATION ---
API_KEY="x"
LOCATION_QUERY="x,US,MO"
UNITS="imperial"

# --- SCRIPT LOGIC ---
API_URL="http://api.openweathermap.org/data/2.5/forecast?q=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
CACHE_FILE="/tmp/waybar_weather_cache.json"
CACHE_TTL=1800

# MODIFIED: Added a check for an empty file to force a refresh.
if ! [ -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_TTL ] || [ ! -s "$CACHE_FILE" ]; then
    curl -sf "$API_URL" > "$CACHE_FILE"
fi

# This second check is still useful as a final safety net.
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

# --- ASSEMBLE FINAL OUTPUT ---
TEXT_OUTPUT="$CURRENT_TEMP"

TOP_LINE="$CURRENT_EMOJI Feels $FEELS_LIKE_TEMP"
TOOLTIP_TITLE="5-Day Forecast"
FULL_TOOLTIP="$TOP_LINE\n\n$TOOLTIP_TITLE\n$TOOLTIP_BODY"

# Escape newlines in the tooltip for valid JSON output for Waybar.
printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"
