#!/usr/bin/env bash

"$(dirname "$0")/current-wallpaper.sh" >/dev/null 2>&1

exec rofi -show drun -config "$HOME/.config/rofi/launcher.rasi"
