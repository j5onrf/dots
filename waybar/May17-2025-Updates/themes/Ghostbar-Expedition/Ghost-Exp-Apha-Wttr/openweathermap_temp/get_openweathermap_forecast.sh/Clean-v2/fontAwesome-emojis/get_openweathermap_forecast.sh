#!/bin/bash
#
# Waybar Weather & Forecast Script (Self-Healing & FontAwesome Emoji Version) 2025-07-01
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

WEATHER_CACHE_TTL=600  # 10 minutes
FORECAST_CACHE_TTL=3600 # 1 hour

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
        800) echo "";; 801) echo "";; 802) echo "";; 803|804) echo "";;
        5*) echo "";;  2*) echo "";;  6*) echo "";;  7*) echo "";;
        *)  echo "";;
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

# --- PARSE 5-DAY FORECAST (SAFE & FAST METHOD) ---
declare -A daily_min daily_max daily_icon daily_day_name

# This loop reads the pre-formatted data. The 'jq' command is simple and only
# adds the "dt_txt" field, which contains a ready-to-use timestamp string.
while IFS=$'\t' read -r dt dt_txt temp_min temp_max weather_id; do
    # OPTIMIZATION: Use fast shell string manipulation to get the date and hour
    # from the "dt_txt" field (e.g., "2025-07-01 18:00:00"). This avoids calling
    # the slow `date` command for every single forecast entry.
    local_date_key=${dt_txt% *}                  # Gets "2025-07-01"
    time_part=${dt_txt#* }                       # Gets "18:00:00"
    local_hour=${time_part%%:*}                  # Gets "18"

    # Get the day name (e.g., "Mon"). This is the only 'date' call left in the
    # loop, and it will only run ONCE per day, making it very fast.
    if [[ -z "${daily_day_name[$local_date_key]}" ]]; then
        daily_day_name[$local_date_key]=$(date -d "@$dt" +'%a')
    fi

    # The rest of this logic is from your original, working script.
    # It correctly chooses a representative icon for the day (preferring the afternoon).
    if (( 10#$local_hour >= 12 && 10#$local_hour <= 15 )); then
        daily_icon[$local_date_key]=$weather_id
    elif [[ -z "${daily_icon[$local_date_key]}" ]]; then
        daily_icon[$local_date_key]=$weather_id
    fi

    # It correctly finds the true minimum and maximum temperatures for the day.
    temp_min_int=${temp_min%.*}
    temp_max_int=${temp_max%.*}
    if [[ -z "${daily_min[$local_date_key]}" ]] || (( temp_min_int < daily_min[$local_date_key] )); then
        daily_min[$local_date_key]=$temp_min_int
    fi
    if [[ -z "${daily_max[$local_date_key]}" ]] || (( temp_max_int > daily_max[$local_date_key] )); then
        daily_max[$local_date_key]=$temp_max_int
    fi
done < <(echo "$FORECAST_RAW_DATA" | jq -r '.list[] | [.dt, .dt_txt, .main.temp_min, .main.temp_max, .weather[0].id] | @tsv')

# This final section for building the tooltip is from your original script.
# Its logic is sound and correctly generates the forecast for the *next* 5 days.
TOOLTIP_FORECAST=""
for i in {1..5}; do
    date_key=$(date -d "today +$i day" +'%Y-%m-%d')
    if [[ -n "${daily_day_name[$date_key]}" ]]; then
        day_name=${daily_day_name[$date_key]}
        min_temp=${daily_min[$date_key]}
        max_temp=${daily_max[$date_key]}
        icon_code=${daily_icon[$date_key]}
        emoji=$(get_emoji $icon_code)
        
        TOOLTIP_FORECAST+="${emoji} ${day_name} ${min_temp}° ${max_temp}°\n"
    fi
done
TOOLTIP_FORECAST=$(echo -e "${TOOLTIP_FORECAST%\\n}")

# --- ASSEMBLE FINAL OUTPUT ---
TEXT_OUTPUT="$CURRENT_TEMP"
TOP_LINE="$CURRENT_EMOJI Feels $FEELS_LIKE_TEMP"
FULL_TOOLTIP="$TOP_LINE\n$CURRENT_CONDITION_TEXT_SHORT\n$TOOLTIP_FORECAST"

# The final printf statement which sends the data to Waybar.
printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT_OUTPUT" "${FULL_TOOLTIP//$'\n'/\\n}"
