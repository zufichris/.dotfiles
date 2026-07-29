#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/matugen_wallpaper"
LAST="$(cat "$STATE_FILE" 2>/dev/null)"

# The watcher mirrors whatever wpaperd is showing back into STATE_FILE, so it
# must not run before the restore lands - otherwise it overwrites the saved
# wallpaper with the one wpaperd defaults to on startup (first file in the
# group), and every later boot then "restores" that one. Hence the chaining:
# the watcher is started from here, not autostarted alongside us.
if [ -n "$LAST" ] && [ -f "$LAST" ]; then
    ~/.config/hypr/scripts/set-wallpaper.sh "$LAST"
elif ! pgrep -x wpaperd >/dev/null; then
    wpaperd >/dev/null 2>&1 &
    disown
fi

exec ~/.config/hypr/scripts/wallpaper-watcher.sh
