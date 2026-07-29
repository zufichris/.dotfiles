#!/usr/bin/env bash

"$(dirname "$0")/current-wallpaper.sh" >/dev/null 2>&1

avatar=$(find ~/Pictures/avatars -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    2>/dev/null | shuf -n1)
if [ -n "$avatar" ]; then
    # Stage + rename instead of copying onto avatar.png directly: hypridle can
    # fire two lock triggers close together (the 600s listener and
    # before_sleep_cmd), and `pidof hyprlock ||` is check-then-act, so a second
    # lock.sh can truncate the file while a running hyprlock is still reading
    # it. rename(2) is atomic - a reader sees the old file or the new one.
    tmp=$(mktemp ~/.config/hypr/.avatar.XXXXXX) || tmp=""
    if [ -n "$tmp" ] && cp -f "$avatar" "$tmp"; then
        chmod 644 "$tmp"
        mv -f "$tmp" ~/.config/hypr/avatar.png
        rm -f ~/.config/hypr/.avatar-auto
    else
        [ -n "$tmp" ] && rm -f "$tmp"
    fi
fi

exec hyprlock
