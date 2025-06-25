#!/bin/bash
# ~/.config/hypr/scripts/get_openweathermap_forecast.sh

# --- CONFIGURATION ---
API_KEY="---"
LOCATION_QUERY="---,US,MO"
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
CURRENT_ICON_CODE=$(echo "$RAW_DATA" | jq -r '.list[0].weather[0].id')
CURRENT_CONDITION_RAW_TEXT=$(echo "$RAW_DATA" | jq -r '.list[0].weather[0].description')

get_emoji() {
    local code=$1
    case "$code" in
        800) echo "☀️";; 801) echo "🌤️";; 802) echo "⛅";; 803|804) echo "☁️";;
        5*) echo "🌧️";;  2*) echo "⛈️";;  6*) echo "❄️";;  7*) echo "🌫️";;
        *)  echo "";;
    esac
}

# MODIFIED FUNCTION: To get a shorter, potentially two-word version of the weather description
get_short_condition_text() {
    local full_desc_raw="$1"
    local full_desc_capitalized=$(echo "$full_desc_raw" | sed -e "s/\b\(.\)/\u\1/g")

    case "$full_desc_capitalized" in
        "Clear Sky") echo "Clear Sky";;
        "Few Clouds") echo "Few Clouds";;
        "Scattered Clouds") echo "Scat. Clouds";;
        "Broken Clouds") echo "Brkn. Clouds";;
        "Overcast Clouds") echo "Ovr. Clouds";; # Shortened "Overcast" to "Ovr."

        "Light Rain") echo "Light Rain";;
        "Moderate Rain") echo "Mod. Rain";;
        "Heavy Intensity Rain") echo "Hvy. Rain";;
        "Very Heavy Rain") echo "V. Hvy Rain";; # Shortened "Very Heavy"
        "Extreme Rain") echo "Ext. Rain";;
        "Freezing Rain") echo "Frz. Rain";;

        "Thunderstorm With Light Rain") echo "T-Storm Rain";; # Concise "Thunderstorm Rain"
        "Thunderstorm With Rain") echo "T-Storm Rain";;
        "Thunderstorm With Heavy Rain") echo "T-Storm HvyR";; # More condensed for heavy T-storms
        "Thunderstorm") echo "T-Storm";;

        "Light Snow") echo "Light Snow";;
        "Heavy Snow") echo "Hvy. Snow";;
        "Sleet") echo "Sleet";;

        # Atmospheric conditions - generally short enough already
        "Mist" | "Fog" | "Haze" | "Smoke" | "Dust" | "Sand" | "Ash" | "Squall" | "Tornado") echo "$full_desc_capitalized";;

        *) echo "$full_desc_capitalized";; # Default to original capitalized if no specific short form
    esac
}

CURRENT_CONDITION_TEXT_SHORT=$(get_short_condition_text "$CURRENT_CONDITION_RAW_TEXT")


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

FULL_TOOLTIP="$TOP_LINE\n$CURRENT_CONDITION_TEXT_SHORT\n$TODAY_FORMATTED\n\n$TOOLTIP_TITLE\n$REST_FORMATTED"

printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"
