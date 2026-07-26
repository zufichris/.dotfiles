#!/usr/bin/env bash
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-weather.json"
MAX_AGE=1800

fresh() {
    [ -f "$CACHE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE"))) -lt $MAX_AGE ]
}

icon_for() {
    case "$1" in
    113) echo "󰖙" ;;
    116) echo "󰖕" ;;
    119 | 122) echo "󰖐" ;;
    143 | 248 | 260) echo "󰖑" ;;
    176 | 263 | 266 | 293 | 296 | 299 | 302 | 305 | 308 | 353 | 356 | 359) echo "󰖗" ;;
    200 | 386 | 389 | 392 | 395) echo "󰖓" ;;
    179 | 227 | 230 | 320 | 323 | 326 | 329 | 332 | 335 | 338 | 368 | 371) echo "󰖘" ;;
    *) echo "󰖐" ;;
    esac
}

if ! fresh; then
    if raw=$(curl -sf --max-time 10 'https://wttr.in/?format=j1'); then
        cur_temp=$(jq -r '.current_condition[0].temp_C' <<<"$raw")
        cur_desc=$(jq -r '.current_condition[0].weatherDesc[0].value' <<<"$raw")
        cur_hum=$(jq -r '.current_condition[0].humidity' <<<"$raw")
        cur_wind=$(jq -r '.current_condition[0].windspeedKmph' <<<"$raw")
        cur_code=$(jq -r '.current_condition[0].weatherCode' <<<"$raw")

        days="[]"
        for i in 0 1 2; do
            d_date=$(jq -r ".weather[$i].date" <<<"$raw")
            d_temp=$(jq -r ".weather[$i].avgtempC" <<<"$raw")
            d_code=$(jq -r ".weather[$i].hourly[4].weatherCode" <<<"$raw")
            d_name=$(date -d "$d_date" '+%a')
            days=$(jq -c --arg d "$d_name" --arg i "$(icon_for "$d_code")" --arg t "${d_temp}°" \
                '. += [{d: $d, i: $i, t: $t}]' <<<"$days")
        done

        jq -cn --arg temp "${cur_temp}°" --arg desc "$cur_desc" \
            --arg hum "${cur_hum}%" --arg wind "${cur_wind} km/h" \
            --arg icon "$(icon_for "$cur_code")" --argjson days "$days" \
            '{temp: $temp, desc: $desc, hum: $hum, wind: $wind, icon: $icon, days: $days}' >"$CACHE"
    fi
fi

if [ -s "$CACHE" ]; then
    cat "$CACHE"
else
    jq -cn '{temp: "--°", desc: "Offline", hum: "--", wind: "--", icon: "󰖐", days: []}'
fi
