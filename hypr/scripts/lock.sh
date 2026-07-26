#!/usr/bin/env bash

"$(dirname "$0")/current-wallpaper.sh" >/dev/null 2>&1

avatar=$(find ~/Pictures/avatars -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    2>/dev/null | shuf -n1)
if [ -n "$avatar" ]; then
    cp -f "$avatar" ~/.config/hypr/avatar.png
    rm -f ~/.config/hypr/.avatar-auto
fi

exec hyprlock
