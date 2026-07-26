#!/usr/bin/env bash

DIR="$HOME/Pictures/screenshots"
mkdir -p "$DIR"
FILE="$DIR/Screenshot-$(date +%F_%T).png"

capture() {
    case "$1" in
    region)
        REGION=$(slurp) || exit 0
        grim -g "$REGION" -
        ;;
    full)
        grim -
        ;;
    esac
}

case "${1:-}" in
region | full) ;;
*)
    echo "Usage: $0 {region|full}"
    exit 1
    ;;
esac

if command -v satty >/dev/null 2>&1; then
    capture "$1" | satty --filename - \
        --output-filename "$FILE" \
        --copy-command wl-copy \
        --early-exit
elif command -v swappy >/dev/null 2>&1; then
    capture "$1" | swappy -f - -o "$FILE"
else
    if capture "$1" >"$FILE"; then
        wl-copy <"$FILE"
        notify-send "Screenshot Saved" "Captured to clipboard & folder" -t 1000 -i "$FILE"
    fi
    exit 0
fi

if [ -s "$FILE" ]; then
    notify-send "Screenshot Saved" "$FILE" -t 1500 -i "$FILE"
fi
