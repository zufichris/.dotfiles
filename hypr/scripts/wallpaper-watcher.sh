#!/usr/bin/env bash

set -u

MONITOR="eDP-1"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/matugen_wallpaper"

while true; do
	if pgrep -x mpvpaper >/dev/null; then
		sleep 5
		continue
	fi
	current=$(wpaperctl get-wallpaper "${MONITOR}" 2>/dev/null || true)
	last=$(cat "${STATE_FILE}" 2>/dev/null || true)
	if [ -n "${current}" ] && [ -f "${current}" ] && [ "${current}" != "${last}" ]; then
		printf '%s\n' "${current}" >"${STATE_FILE}"
		cp -f "${current}" "$HOME/.cache/current_wallpaper"
		~/.config/hypr/scripts/apply-theme.sh "${current}"
	fi
	sleep 5
done
