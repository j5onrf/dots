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

if ! [ -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_TTL ] || [ ! -s "$CACHE_FILE" ]; then
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

CURRENT_TEMP=$(echo "$RAW_DATA" | jq '.list[0].main.temp' | awk '{printf "%.0f°", $1}')
FEELS_LIKE_TEMP=$(echo "$RAW_DATA" | jq '.list[0].main.feels_like' | awk '{printf "%.0f°", $1}')

get_emoji() {
    local code=$1
    case "$code" in
        800) echo "☀️";; 801) echo "🌤️";; 802) echo "⛅";; 803|804) echo "☁️";;
        5*) echo "🌧️";;  2*) echo "⛈️";;  6*) echo "❄️";;  7*) echo "🌫️";;
        *)  echo "";;
    esac
}

# --- PARSE 6-DAY FORECAST ---
FORECAST_DATA_RAW=$(echo "$RAW_DATA" | jq -r '
    .list | group_by(.dt_txt | .[:10]) | .[0:6] |
    map(
        { day: (.[0].dt_txt | strptime("%Y-%m-%d %H:%M:%S") | strftime("%a")),
          min: (map(.main.temp_min) | min | round),
          max: (map(.main.temp_max) | max | round),
          id: (.[4].weather[0].id // .[0].weather[0].id) }
        | "\(.day):\(.min):\(.max):\(.id)"
    ) | .[]
')

# --- Process Today and The Rest of the Forecast Separately ---
TODAY_RAW=$(echo "$FORECAST_DATA_RAW" | head -n 1)
IFS=':' read -r day min max id <<< "$TODAY_RAW"
emoji=$(get_emoji $id)
TODAY_FORMATTED="${emoji} ${day} ${min}° ${max}°"

REST_RAW=$(echo "$FORECAST_DATA_RAW" | tail -n +2)
REST_FORMATTED=""
while IFS= read -r line; do
    IFS=':' read -r day min max id <<< "$line"
    emoji=$(get_emoji $id)
    REST_FORMATTED+="${emoji} ${day} ${min}° ${max}°\n"
done <<< "$REST_RAW"
REST_FORMATTED=$(echo -e "${REST_FORMATTED%\\n}")

# --- ASSEMBLE FINAL OUTPUT ---
TEXT_OUTPUT="$CURRENT_TEMP"
TOP_LINE="Feels $FEELS_LIKE_TEMP"
TOOLTIP_TITLE="→ Next 5 Days"

# MODIFIED: Assembling the final tooltip in the exact order you requested.
FULL_TOOLTIP="$TOP_LINE\n$TODAY_FORMATTED\n\n$TOOLTIP_TITLE\n$REST_FORMATTED"

printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"