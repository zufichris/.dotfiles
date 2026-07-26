#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/matugen_wallpaper"
LAST="$(cat "$STATE_FILE" 2>/dev/null)"

if [ -n "$LAST" ] && [ -f "$LAST" ]; then
    exec ~/.config/hypr/scripts/set-wallpaper.sh "$LAST"
fi

exec wpaperd
