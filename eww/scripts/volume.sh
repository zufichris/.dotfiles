#!/usr/bin/env bash
case "$1" in
    get)
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}'
        ;;
    set)
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$(printf '%.0f' "$2")%"
        ;;
esac
