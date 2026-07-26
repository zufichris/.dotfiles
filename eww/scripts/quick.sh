#!/usr/bin/env bash
case "${1:-status}" in
status)
    wifi=false
    [ "$(timeout 2 nmcli radio wifi 2>/dev/null)" = "enabled" ] && wifi=true
    bt=false
    timeout 2 bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && bt=true
    dnd=$(timeout 2 swaync-client -D 2>/dev/null || echo false)
    notifs=$(timeout 2 swaync-client -c 2>/dev/null || echo 0)
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
