#!/usr/bin/env bash
# Toggle/close the eww dashboard, resilient to orphaned eww daemons.
#
# When the eww daemon misses one IPC request, `eww open --toggle` silently
# forks a NEW daemon that steals the socket and opens its own dashboard —
# the old daemon's window stays on screen and is unreachable over IPC
# forever. So: close by killing the PIDs that own eww-dashboard layers
# (from Hyprland's layer list), and health-check the daemon before opening.

dash_pids() {
    hyprctl -j layers | jq -r '.. | objects | select(.namespace? == "eww-dashboard") | .pid' | sort -u
}

close_all() {
    timeout 2 eww close dashboard >/dev/null 2>&1
    sleep 0.1
    local pids
    pids=$(dash_pids)
    if [ -n "$pids" ]; then
        kill $pids 2>/dev/null
        sleep 0.3
        pids=$(dash_pids)
        [ -n "$pids" ] && kill -9 $pids 2>/dev/null
    fi
}

open_dash() {
    if ! timeout 1 eww ping >/dev/null 2>&1; then
        pkill -x eww 2>/dev/null
        sleep 0.3
        pkill -9 -x eww 2>/dev/null
    fi
    eww open dashboard >/dev/null 2>&1
}

case "${1:-toggle}" in
close) close_all ;;
open) open_dash ;;
toggle)
    if [ -n "$(dash_pids)" ]; then
        close_all
    else
        open_dash
    fi
    ;;
esac
