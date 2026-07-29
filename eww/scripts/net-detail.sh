#!/usr/bin/env bash
# Wi-Fi/VPN detail for the quick-settings expander.
# -> {"ssid":"Home","signal":72,"vpn":"","ip":"192.168.1.4/24"}
ssid=""
signal=0
if wifi=$(timeout 3 nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print $2 "\t" $3; exit}'); then
    ssid=${wifi%%$'\t'*}
    signal=${wifi##*$'\t'}
fi
vpn=$(timeout 3 nmcli -t -f TYPE,NAME connection show --active 2>/dev/null |
    awk -F: '$1 == "vpn" || $1 == "wireguard" {print $2; exit}')
ip=$(timeout 3 nmcli -t -f IP4.ADDRESS device show 2>/dev/null |
    awk -F: '/IP4.ADDRESS/ && $2 != "" {print $2; exit}')
jq -cn --arg s "$ssid" --argjson sig "${signal:-0}" --arg v "$vpn" --arg ip "$ip" \
    '{ssid: $s, signal: $sig, vpn: $v, ip: $ip}'
