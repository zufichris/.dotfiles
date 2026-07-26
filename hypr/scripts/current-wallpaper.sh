#!/usr/bin/env bash

CACHE="$HOME/.cache/current_wallpaper"

if pgrep -x mpvpaper >/dev/null 2>&1; then
    echo "$CACHE"
    exit 0
fi

monitor=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name' 2>/dev/null)

wall=""
if [ -n "$monitor" ]; then
    wall=$(wpaperctl get-wallpaper "$monitor" 2>/dev/null)
fi

if [ -z "$wall" ] || [ ! -f "$wall" ]; then
    wall=$(find -L "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        2>/dev/null | head -n 1)
fi

if [ -n "$wall" ] && [ -f "$wall" ] && ! cmp -s "$wall" "$CACHE"; then
    cp -f "$wall" "$CACHE"
fi

echo "$CACHE"
