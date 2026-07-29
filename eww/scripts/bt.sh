#!/usr/bin/env bash
# Bluetooth device list for the quick-settings expander.
# list -> [{"mac":"AA:BB:...","name":"Buds","connected":true,"battery":80}]
#         battery -1 when the device doesn't report it
case "${1:-list}" in
list)
    command -v bluetoothctl >/dev/null 2>&1 || { echo "[]"; exit 0; }
    devices=$(timeout 3 bluetoothctl devices Paired 2>/dev/null)
    [ -n "$devices" ] || devices=$(timeout 3 bluetoothctl devices 2>/dev/null)
    out="[]"
    while read -r _ mac name; do
        [ -n "$mac" ] || continue
        info=$(timeout 3 bluetoothctl info "$mac" 2>/dev/null)
        conn=false
        grep -q "Connected: yes" <<<"$info" && conn=true
        batt=$(grep -oP 'Battery Percentage: 0x[0-9a-fA-F]+ \(\K[0-9]+' <<<"$info")
        out=$(jq -c --arg m "$mac" --arg n "$name" --argjson c "$conn" --argjson b "${batt:--1}" \
            '. += [{mac: $m, name: $n, connected: $c, battery: $b}]' <<<"$out")
    done <<<"$devices"
    echo "$out"
    ;;
connect) timeout 10 bluetoothctl connect "$2" >/dev/null 2>&1 ;;
disconnect) timeout 10 bluetoothctl disconnect "$2" >/dev/null 2>&1 ;;
esac
