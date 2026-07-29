#!/usr/bin/env bash
# Open rofi drun pre-filtered with the query, then close the dashboard.
# rofi is detached first: dashboard.sh close can kill the eww daemon,
# which is this script's process ancestor.
q="$*"
setsid -f bash -c 'sleep 0.35; exec rofi -show drun -filter "$1" -config ~/.config/rofi/launcher.rasi' _ "$q" >/dev/null 2>&1
exec "$HOME/.config/hypr/scripts/dashboard.sh" close
