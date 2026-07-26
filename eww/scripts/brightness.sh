#!/usr/bin/env bash
case "$1" in
    get)
        brightnessctl -m | awk -F, '{gsub("%",""); printf "%d", $4}'
        ;;
    set)
        brightnessctl set "$(printf '%.0f' "$2")%" >/dev/null
        ;;
esac
