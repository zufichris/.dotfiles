#!/usr/bin/env bash
# Quick-settings state. The four probes are independent and each costs
# 15-30ms, so run them concurrently: sequential they add up to ~160ms on
# every poll. timeouts stay, an earlier hang here stalled the whole panel.
RT="${XDG_RUNTIME_DIR:-/tmp}"

case "${1:-status}" in
status)
    timeout 2 nmcli radio wifi >"$RT/eww-q-wifi" 2>/dev/null &
    timeout 2 bluetoothctl show >"$RT/eww-q-bt" 2>/dev/null &
    timeout 2 swaync-client -D >"$RT/eww-q-dnd" 2>/dev/null &
    timeout 2 swaync-client -c >"$RT/eww-q-n" 2>/dev/null &
    wait

    wifi=false
    [ "$(cat "$RT/eww-q-wifi" 2>/dev/null)" = "enabled" ] && wifi=true
    bt=false
    grep -q "Powered: yes" "$RT/eww-q-bt" 2>/dev/null && bt=true
    dnd=$(cat "$RT/eww-q-dnd" 2>/dev/null)
    case "$dnd" in true | false) ;; *) dnd=false ;; esac
    notifs=$(cat "$RT/eww-q-n" 2>/dev/null)
    case "$notifs" in '' | *[!0-9]*) notifs=0 ;; esac
    caffeine=true
    pgrep -x hypridle >/dev/null && caffeine=false

    jq -cn --argjson w "$wifi" --argjson b "$bt" --argjson d "$dnd" --argjson n "$notifs" --argjson c "$caffeine" \
        '{wifi: $w, bt: $b, dnd: $d, notifs: $n, caffeine: $c}'
    ;;
wifi)
    if [ "$(nmcli radio wifi)" = "enabled" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi
    ;;
bt)
    if bluetoothctl show | grep -q "Powered: yes"; then bluetoothctl power off; else bluetoothctl power on; fi
    ;;
dnd)
    swaync-client -d
    ;;
caffeine)
    if pgrep -x hypridle >/dev/null; then
        pkill -x hypridle
    else
        setsid hypridle >/dev/null 2>&1 &
    fi
    ;;
esac
