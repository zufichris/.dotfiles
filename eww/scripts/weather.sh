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

# stale-format caches (pre-hourly) regenerate too
if ! fresh || ! jq -e 'has("hourly")' "$CACHE" >/dev/null 2>&1; then
    if raw=$(curl -sf --max-time 10 'https://wttr.in/?format=j1'); then
        cur_temp=$(jq -r '.current_condition[0].temp_C' <<<"$raw")
        cur_desc=$(jq -r '.current_condition[0].weatherDesc[0].value' <<<"$raw")
        cur_hum=$(jq -r '.current_condition[0].humidity' <<<"$raw")
        cur_wind=$(jq -r '.current_condition[0].windspeedKmph' <<<"$raw")
        cur_code=$(jq -r '.current_condition[0].weatherCode' <<<"$raw")

        days="[]"
        for i in 0 1 2; do
            d_date=$(jq -r ".weather[$i].date" <<<"$raw")
            d_hi=$(jq -r ".weather[$i].maxtempC" <<<"$raw")
            d_lo=$(jq -r ".weather[$i].mintempC" <<<"$raw")
            d_code=$(jq -r ".weather[$i].hourly[4].weatherCode" <<<"$raw")
            d_precip=$(jq -r "[.weather[$i].hourly[].chanceofrain | tonumber] | max" <<<"$raw")
            if [ "$i" -eq 0 ]; then d_name="Today"; else d_name=$(date -d "$d_date" '+%a'); fi
            days=$(jq -c --arg d "$d_name" --arg i "$(icon_for "$d_code")" \
                --arg hi "${d_hi}°" --arg lo "${d_lo}°" --argjson p "$d_precip" \
                '. += [{d: $d, i: $i, hi: $hi, lo: $lo, p: $p}]' <<<"$days")
        done

        # next 8 three-hour slots for the hover-expand row
        hourly="[]"
        count=0
        nowh=$(date +%-H)
        for day in 0 1; do
            n=$(jq -r ".weather[$day].hourly | length" <<<"$raw")
            k=0
            while [ "$k" -lt "$n" ] && [ "$count" -lt 8 ]; do
                t=$(jq -r ".weather[$day].hourly[$k].time" <<<"$raw")
                h=$((t / 100))
                if [ "$day" -eq 0 ] && [ "$h" -lt "$nowh" ]; then k=$((k + 1)); continue; fi
                h_temp=$(jq -r ".weather[$day].hourly[$k].tempC" <<<"$raw")
                h_code=$(jq -r ".weather[$day].hourly[$k].weatherCode" <<<"$raw")
                hourly=$(jq -c --arg h "${h}h" --arg i "$(icon_for "$h_code")" --arg t "${h_temp}°" \
                    '. += [{h: $h, i: $i, t: $t}]' <<<"$hourly")
                count=$((count + 1))
                k=$((k + 1))
            done
        done

        jq -cn --arg temp "${cur_temp}°" --arg desc "$cur_desc" \
            --arg hum "${cur_hum}%" --arg wind "${cur_wind} km/h" \
            --arg icon "$(icon_for "$cur_code")" --argjson days "$days" --argjson hourly "$hourly" \
            '{temp: $temp, desc: $desc, hum: $hum, wind: $wind, icon: $icon, days: $days, hourly: $hourly}' >"$CACHE"
    fi
fi

if [ -s "$CACHE" ] && jq -e 'has("hourly")' "$CACHE" >/dev/null 2>&1; then
    cat "$CACHE"
else
    jq -cn '{temp: "--°", desc: "Offline", hum: "--", wind: "--", icon: "󰖐", days: [], hourly: []}'
fi
