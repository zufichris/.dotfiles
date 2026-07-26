#!/usr/bin/env bash
ZONE="/sys/class/thermal/thermal_zone2/temp"
[ -r "$ZONE" ] && awk '{printf "%d", $1 / 1000}' "$ZONE" || echo 0
