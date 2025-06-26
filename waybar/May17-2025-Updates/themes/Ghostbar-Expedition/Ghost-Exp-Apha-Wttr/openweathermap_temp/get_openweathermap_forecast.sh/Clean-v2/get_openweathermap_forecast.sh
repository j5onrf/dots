#!/bin/bash
#
# Waybar Weather & Forecast Script
#
# A robust script to display current temperature and a multi-day forecast
# for Waybar, optimized for reliability and clear configuration.
#
# Author: j5onrf
# Path: ~/.config/hypr/scripts/get_openweathermap_forecast.sh

# --- CONFIGURATION ---
# You MUST configure the 3 settings in this section to use the script.

# 1. API_KEY: Get your free API key from https://openweathermap.org/
API_KEY="YOUR_API_KEY_HERE"

# 2. LOCATION_QUERY: Set this to your unique City ID.
#    (See instructions below on how to find your ID)
LOCATION_QUERY="0000000" # <-- Replace with your City ID

# 3. UNITS: Choose your preferred measurement system.
UNITS="imperial" # Options: "metric" for Celsius, "imperial" for Fahrenheit


# --- HOW TO FIND YOUR CITY ID ---
# This script requires a City ID for the fastest and most reliable weather lookup.
#
# 1. Go to openweathermap.org and search for your city.
# 2. Click the correct city name in the search results.
# 3. Look at the URL in your browser's address bar. It will be like this:
#    https://openweathermap.org/city/0000000  <-- This number is your ID
#
# 4. Copy that number and paste it into the LOCATION_QUERY variable above.


# --- SCRIPT SETUP (Do not edit below this line) ---
API_URL="http://api.openweathermap.org/data/2.5/forecast?id=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
# Create a unique cache file based on location to support multiple instances
CACHE_FILE="/tmp/waybar_weather_$(echo -n "$LOCATION_QUERY" | md5sum | cut -d' ' -f1).json"
CACHE_TTL=1800

# Superior self-healing cache logic.
if ! [ -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_TTL ] || [ ! -s "$CACHE_FILE" ]; then
    curl -sf "$API_URL" > "$CACHE_FILE"
fi

# Final safety net check.
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
CURRENT_CONDITION_RAW_TEXT=$(echo "$RAW_DATA" | jq -r '.list[0].weather[0].description')

get_emoji() {
    local code=$1
    case "$code" in
        800) echo "☀️";; 801) echo "🌤️";; 802) echo "⛅";; 803|804) echo "☁️";;
        5*) echo "🌧️";;  2*) echo "⛈️";;  6*) echo "❄️";;  7*) echo "🌫️";;
        *)  echo "";;
    esac
}

get_short_condition_text() {
    local full_desc_raw="$1"
    local full_desc_capitalized=$(echo "$full_desc_raw" | sed -e "s/\b\(.\)/\u\1/g")
    case "$full_desc_capitalized" in
        "Clear Sky") echo "Clear Sky";; "Few Clouds") echo "Few Clouds";; "Scattered Clouds") echo "Scat. Clouds";;
        "Broken Clouds") echo "Brkn. Clouds";; "Overcast Clouds") echo "Ovr. Clouds";; "Light Rain") echo "Light Rain";;
        "Moderate Rain") echo "Mod. Rain";; "Heavy Intensity Rain") echo "Hvy. Rain";; "Very Heavy Rain") echo "V. Hvy Rain";;
        "Extreme Rain") echo "Ext. Rain";; "Freezing Rain") echo "Frz. Rain";; "Thunderstorm With Light Rain") echo "T-Storm Rain";;
        "Thunderstorm With Rain") echo "T-Storm Rain";; "Thunderstorm With Heavy Rain") echo "T-Storm HvyR";; "Thunderstorm") echo "T-Storm";;
        "Light Snow") echo "Light Snow";; "Heavy Snow") echo "Hvy. Snow";; "Sleet") echo "Sleet";;
        "Mist" | "Fog" | "Haze" | "Smoke" | "Dust" | "Sand" | "Ash" | "Squall" | "Tornado") echo "$full_desc_capitalized";;
        *) echo "$full_desc_capitalized";;
    esac
}

CURRENT_CONDITION_TEXT_SHORT=$(get_short_condition_text "$CURRENT_CONDITION_RAW_TEXT")

# --- PARSE FORECAST (TIMEZONE-CORRECT, ROBUST METHOD) ---
declare -A daily_min daily_max daily_icon daily_day_name
while IFS=$'\t' read -r dt temp_min temp_max weather_id; do
    local_date_key=$(date -d "@$dt" +'%Y-%m-%d')
    if [[ -z "${daily_day_name[$local_date_key]}" ]]; then
        daily_day_name[$local_date_key]=$(date -d "@$dt" +'%a')
    fi
    local_hour=$(date -d "@$dt" +'%H')
    if (( local_hour >= 12 && local_hour <= 15 )); then
        daily_icon[$local_date_key]=$weather_id
    elif [[ -z "${daily_icon[$local_date_key]}" ]]; then
        daily_icon[$local_date_key]=$weather_id
    fi
    temp_min_int=${temp_min%.*}
    temp_max_int=${temp_max%.*}
    if [[ -z "${daily_min[$local_date_key]}" ]] || (( temp_min_int < daily_min[$local_date_key] )); then
        daily_min[$local_date_key]=$temp_min_int
    fi
    if [[ -z "${daily_max[$local_date_key]}" ]] || (( temp_max_int > daily_max[$local_date_key] )); then
        daily_max[$local_date_key]=$temp_max_int
    fi
done < <(echo "$RAW_DATA" | jq -r '.list[] | [.dt, .main.temp_min, .main.temp_max, .weather[0].id] | @tsv')

FORECAST_DATA_RAW=""
day_count=0
for date_key in $(echo "${!daily_day_name[@]}" | tr ' ' '\n' | sort); do
    if (( day_count < 6 )); then
        day_name=${daily_day_name[$date_key]}
        min_temp=${daily_min[$date_key]}
        max_temp=${daily_max[$date_key]}
        icon_code=${daily_icon[$date_key]}
        FORECAST_DATA_RAW+="${day_name}:${min_temp}:${max_temp}:${icon_code}\n"
        ((day_count++))
    fi
done

# --- PARSING LOGIC ---
TODAY_RAW=$(echo -e "$FORECAST_DATA_RAW" | head -n 1)
IFS=':' read -r day min max id <<< "$TODAY_RAW"
emoji=$(get_emoji $id)
TODAY_FORMATTED="${emoji} ${day} ${min}° ${max}°"

REST_RAW=$(echo -e "$FORECAST_DATA_RAW" | tail -n +2)
REST_FORMATTED=""
while IFS= read -r line; do
    IFS=':' read -r day min max id <<< "$line"
    emoji=$(get_emoji $id)
    REST_FORMATTED+="${emoji} ${day} ${min}° ${max}°\n"
done <<< "$REST_RAW"
REST_FORMATTED=$(echo -e "${REST_FORMATTED%\\n}")

# --- ASSEMBLE FINAL OUTPUT ---
# Thin space for left padding on the temperature.
TEXT_OUTPUT=" $CURRENT_TEMP"
TOP_LINE="Feels $FEELS_LIKE_TEMP"
TOOLTIP_TITLE="→ Next 5 Days"

FULL_TOOLTIP="$TOP_LINE\n$CURRENT_CONDITION_TEXT_SHORT\n$TODAY_FORMATTED\n\n$TOOLTIP_TITLE\n$REST_FORMATTED"

printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"
