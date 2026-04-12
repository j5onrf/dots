#!/bin/bash
#
# Waybar Weather & Forecast Script (Self-Healing & FontAwesome Emoji Version)(Claude Optimized) 2025-07-01
#

# --- CONFIGURATION ---
# You MUST configure the 3 settings in this section to use the script.

# 1. API_KEY: Get your free API key from https://openweathermap.org/
API_KEY="your-api-key"

# 2. LOCATION_QUERY: Set this to your unique City ID.
#    (See instructions in the "HOW-TO" section below this block)
LOCATION_QUERY="0000000" # <-- Replace with your City ID

# 3. UNITS: Choose your preferred measurement system.
UNITS="imperial" # Options: "metric" for Celsius, "imperial" for Fahrenheit


# --- HOW TO FIND YOUR CITY ID (for LOCATION_QUERY) ---
# This script is optimized to use a City ID for the fastest and most reliable
# weather lookup.
#
# 1. Go to openweathermap.org and search for your city.
# 2. Click the correct city name in the search results.
# 3. Look at the URL in your browser's address bar. It will be like this:
#    https://openweathermap.org/city/000000 <-- This number is your ID
#
# 4. Copy that number and paste it into the LOCATION_QUERY variable above.

# --- SCRIPT SETUP ---
WEATHER_API_URL="http://api.openweathermap.org/data/2.5/weather?id=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
FORECAST_API_URL="http://api.openweathermap.org/data/2.5/forecast?id=${LOCATION_QUERY}&appid=${API_KEY}&units=${UNITS}"
WEATHER_CACHE_FILE="/tmp/waybar_weather_current_$(echo -n "$LOCATION_QUERY" | md5sum | cut -d' ' -f1).json"
FORECAST_CACHE_FILE="/tmp/waybar_weather_forecast_$(echo -n "$LOCATION_QUERY" | md5sum | cut -d' ' -f1).json"
WEATHER_CACHE_TTL=3600   # 1 hour (up from 10 minutes)
FORECAST_CACHE_TTL=7200  # 2 hours (up from 1 hour)
# --- DATA FETCHING & VALIDATION ---
if ! [ -f "$WEATHER_CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$WEATHER_CACHE_FILE"))) -gt $WEATHER_CACHE_TTL ] || [ ! -s "$WEATHER_CACHE_FILE" ]; then
    curl -sf "$WEATHER_API_URL" > "$WEATHER_CACHE_FILE"
fi
if ! [ -f "$FORECAST_CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$FORECAST_CACHE_FILE"))) -gt $FORECAST_CACHE_TTL ] || [ ! -s "$FORECAST_CACHE_FILE" ]; then
    curl -sf "$FORECAST_API_URL" > "$FORECAST_CACHE_FILE"
fi
if [ ! -s "$WEATHER_CACHE_FILE" ] || [ ! -s "$FORECAST_CACHE_FILE" ]; then
    printf '{"text": "ERR", "tooltip": "Data fetch failed."}\n'
    exit 1
fi
WEATHER_RAW_DATA=$(cat "$WEATHER_CACHE_FILE")
FORECAST_RAW_DATA=$(cat "$FORECAST_CACHE_FILE")
if [ "$(echo "$WEATHER_RAW_DATA" | jq -r '.cod')" != "200" ] || [ "$(echo "$FORECAST_RAW_DATA" | jq -r '.cod')" != "200" ]; then
    printf '{"text": "API?", "tooltip": "API Error"}\n'
    exit 1
fi
# --- PARSE CURRENT DATA ---
CURRENT_TEMP=$(echo "$WEATHER_RAW_DATA" | jq '.main.temp' | awk '{printf "%.0f°", $1}')
FEELS_LIKE_TEMP=$(echo "$WEATHER_RAW_DATA" | jq '.main.feels_like' | awk '{printf "%.0f°", $1}')
CURRENT_CONDITION_RAW_TEXT=$(echo "$WEATHER_RAW_DATA" | jq -r '.weather[0].description')
CURRENT_ICON_CODE=$(echo "$WEATHER_RAW_DATA" | jq -r '.weather[0].id')
# --- HELPER FUNCTIONS ---
get_emoji() {
    local code=$1
    case "$code" in
        800) printf "\uf185";; # sun
        801) printf "\uf6c4";; # sun behind small cloud  
        802) printf "\uf0c2";; # cloud
        803|804) printf "\uf0c2";; # clouds
        5*) printf "\uf73d";;  # cloud rain
        2*) printf "\uf0e7";;  # bolt (thunderstorm)
        6*) printf "\uf2dc";;  # snowflake
        7*) printf "\uf75f";;  # smog/mist
        *) printf "\uf2c9";;   # thermometer-half
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
CURRENT_EMOJI=$(get_emoji $CURRENT_ICON_CODE)

# --- OPTIMIZED 5-DAY FORECAST PROCESSING ---
declare -A daily_min daily_max daily_icon daily_day_name

# Pre-calculate future dates to avoid repetitive date calculations
declare -a future_dates
for i in {1..5}; do
    future_dates[i]=$(date -d "today +$i day" '+%Y-%m-%d')
done

# Single jq call to extract all needed data, then process in bash
# This reduces the number of jq processes from potentially dozens to just one
while IFS=$'\t' read -r dt dt_txt temp_min temp_max weather_id; do
    # Fast string manipulation to extract date and hour (keeping original working logic)
    local_date_key=${dt_txt% *}                  # Gets "2025-07-01"
    time_part=${dt_txt#* }                       # Gets "18:00:00"
    local_hour=${time_part%%:*}                  # Gets "18"
    
    # Skip processing if this date isn't in our forecast range
    # This optimization reduces unnecessary processing
    skip_date=true
    for future_date in "${future_dates[@]}"; do
        if [[ "$local_date_key" == "$future_date" ]]; then
            skip_date=false
            break
        fi
    done
    [[ "$skip_date" == true ]] && continue
    
    # Get day name only once per date (cached in associative array)
    if [[ -z "${daily_day_name[$local_date_key]}" ]]; then
        daily_day_name[$local_date_key]=$(date -d "@$dt" '+%a')
    fi
    
    # Prefer afternoon icons (12-15h) for better day representation
    if (( 10#$local_hour >= 12 && 10#$local_hour <= 15 )); then
        daily_icon[$local_date_key]=$weather_id
    elif [[ -z "${daily_icon[$local_date_key]}" ]]; then
        daily_icon[$local_date_key]=$weather_id
    fi
    
    # Track min/max temperatures using integer arithmetic (faster than float)
    temp_min_int=${temp_min%.*}
    temp_max_int=${temp_max%.*}
    
    if [[ -z "${daily_min[$local_date_key]}" ]] || (( temp_min_int < daily_min[$local_date_key] )); then
        daily_min[$local_date_key]=$temp_min_int
    fi
    
    if [[ -z "${daily_max[$local_date_key]}" ]] || (( temp_max_int > daily_max[$local_date_key] )); then
        daily_max[$local_date_key]=$temp_max_int
    fi
done < <(echo "$FORECAST_RAW_DATA" | jq -r '.list[] | [.dt, .dt_txt, .main.temp_min, .main.temp_max, .weather[0].id] | @tsv')

# Build forecast tooltip using array for better performance
forecast_lines=()
for i in {1..5}; do
    date_key="${future_dates[i]}"
    if [[ -n "${daily_day_name[$date_key]}" ]]; then
        emoji=$(get_emoji "${daily_icon[$date_key]}")
        forecast_lines+=("${emoji} ${daily_day_name[$date_key]} ${daily_min[$date_key]}° ${daily_max[$date_key]}°")
    fi
done

# Join forecast lines efficiently
TOOLTIP_FORECAST=""
for line in "${forecast_lines[@]}"; do
    TOOLTIP_FORECAST+="$line\n"
done
TOOLTIP_FORECAST=${TOOLTIP_FORECAST%\\n}  # Remove trailing newline

# --- ASSEMBLE FINAL OUTPUT ---
TEXT_OUTPUT="$CURRENT_TEMP"
TOP_LINE="$CURRENT_EMOJI Feels $FEELS_LIKE_TEMP"
FULL_TOOLTIP="$TOP_LINE\n$CURRENT_CONDITION_TEXT_SHORT\n$TOOLTIP_FORECAST"
# The final printf statement which sends the data to Waybar.
printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"
