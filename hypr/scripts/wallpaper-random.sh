#!/usr/bin/env bash
# Apply a random wallpaper (same file set as wallpaper-picker.sh). Theming
# follows via set-wallpaper.sh's matugen pipeline.
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
pick=$(find -L "$WALLPAPER_DIR" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.mov' \) 2>/dev/null | shuf -n1)
[ -n "$pick" ] && exec "$HOME/.config/hypr/scripts/set-wallpaper.sh" "$pick"
