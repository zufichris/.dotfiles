#!/usr/bin/env bash

DIR="$HOME/Videos/recordings"

if pgrep -x wl-screenrec >/dev/null; then
    pkill -INT -x wl-screenrec
    notify-send "Recording Stopped" "Saved to $DIR" -t 2000
    exit 0
fi

if ! command -v wl-screenrec >/dev/null 2>&1; then
    notify-send "Recording Unavailable" "wl-screenrec is not installed" -t 3000
    exit 1
fi

mkdir -p "$DIR"
FILE="$DIR/Recording-$(date +%F_%T).mp4"
notify-send "Recording Started" "Press the record button again to stop" -t 2000
wl-screenrec -f "$FILE"
