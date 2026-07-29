#!/usr/bin/env bash
# Battery + power profile.
# status -> {"batt":76,"charging":false,"time":"2.1h","profile":"balanced","tier":"ok"}
# Reads sysfs directly and gets the profile over D-Bus: `powerprofilesctl get`
# is a Python script and costs ~500ms, busctl costs ~7ms.
BAT=/sys/class/power_supply/BAT0

profile_get() {
    p=$(busctl --system get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles \
        net.hadess.PowerProfiles ActiveProfile 2>/dev/null)
    p=${p#s }
    p=${p//\"/}
    [ -n "$p" ] && { printf '%s' "$p"; return; }
    timeout 4 powerprofilesctl get 2>/dev/null
}

case "${1:-status}" in
status)
    cap=$(cat "$BAT/capacity" 2>/dev/null)
    cap=${cap:-100}
    st=$(cat "$BAT/status" 2>/dev/null)
    charging=false
    case "$st" in Charging | Full | "Not charging") charging=true ;; esac

    # time remaining from the charge/discharge rate, no upower round-trip
    t=""
    if [ -r "$BAT/power_now" ] && [ -r "$BAT/energy_now" ]; then
        rate=$(cat "$BAT/power_now")
        now=$(cat "$BAT/energy_now")
        full=$(cat "$BAT/energy_full" 2>/dev/null || echo 0)
        if [ "${rate:-0}" -gt 0 ] 2>/dev/null; then
            [ "$charging" = true ] && rem=$((full - now)) || rem=$now
            mins=$((rem * 60 / rate))
            if [ "$mins" -ge 60 ]; then
                t="$((mins / 60))h $((mins % 60))m"
            elif [ "$mins" -gt 0 ]; then
                t="${mins}m"
            fi
        fi
    fi

    tier=ok
    if [ "$charging" = false ]; then
        [ "$cap" -le 30 ] && tier=warn
        [ "$cap" -le 15 ] && tier=crit
    fi
    jq -cn --argjson b "$cap" --argjson c "$charging" --arg t "$t" \
        --arg p "$(profile_get)" --arg tier "$tier" \
        '{batt: $b, charging: $c, time: $t, profile: $p, tier: $tier}'
    ;;
set) powerprofilesctl set "$2" ;;
cycle)
    case "$(profile_get)" in
    power-saver) powerprofilesctl set balanced ;;
    balanced) powerprofilesctl set performance ;;
    *) powerprofilesctl set power-saver ;;
    esac
    ;;
esac
