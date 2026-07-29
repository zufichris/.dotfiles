#!/usr/bin/env bash
# Toggle/close the eww dashboard, resilient to orphaned eww daemons.
#
# When the eww daemon misses one IPC request, `eww open --toggle` silently
# forks a NEW daemon that steals the socket and opens its own dashboard, and
# the old daemon's window stays on screen, unreachable over IPC forever.
# So: close by killing the PIDs that own eww-dashboard layers
# (from Hyprland's layer list), and health-check the daemon before opening.

dash_pids() {
    hyprctl -j layers | jq -r '.. | objects | select(.namespace? == "eww-dashboard") | .pid' | sort -u
}

# Name of the monitor currently showing the dashboard, empty if it is closed.
dash_monitor() {
    hyprctl -j layers |
        jq -r 'to_entries[] | select([.value.levels[][]?.namespace] | index("eww-dashboard")) | .key'
}

focused_monitor() {
    hyprctl -j monitors | jq -r '.[] | select(.focused) | .name'
}

# eww cannot resolve connector names here - it only knows GDK model strings
# ("0x14A8"), so `--screen eDP-1` fails and windows must be targeted by numeric
# index. eww numbers monitors 0..n-1 while Hyprland ids go sparse after a
# hotplug, so use the position in the id-sorted list, not the id itself.
focused_index() {
    hyprctl -j monitors | jq -r 'sort_by(.id) | to_entries[] | select(.value.focused) | .key'
}

monitor_count() {
    hyprctl -j monitors | jq 'length'
}

close_all() {
    timeout 2 eww close dashboard >/dev/null 2>&1
    # Wait for the compositor to unmap before assuming the daemon is stuck.
    # Killing a healthy daemon here costs ~2s on the next open (cold start),
    # so only fall through to killing genuine orphans.
    local i pids
    for i in $(seq 12); do
        if [ -z "$(dash_pids)" ]; then
            reset_state
            return 0
        fi
        sleep 0.1
    done
    pids=$(dash_pids)
    if [ -n "$pids" ]; then
        kill $pids 2>/dev/null
        sleep 0.3
        pids=$(dash_pids)
        [ -n "$pids" ] && kill -9 $pids 2>/dev/null
    fi
}

# Clear leftover UI state (typed search text, expanded panels, dismissed
# banner). Done on close, not open, so it never adds latency to opening.
reset_state() {
    eww update banner_dismissed=false search_q='' todo_q='' \
        net_open=false bt_open=false sink_open=false sys_cores=false \
        wx_hourly=false >/dev/null 2>&1
}

open_dash() {
    # The window's `:monitor 0` in eww.yuck is always the built-in panel, so on
    # a docked setup the dashboard would open on the laptop no matter where the
    # focus is. --screen overrides it per open.
    local foc idx i n
    foc=$(focused_monitor)
    idx=$(focused_index)
    [ -n "$idx" ] || idx=0

    # No `eww ping` pre-check: it round-trips through the daemon's main loop,
    # which can be busy servicing polls, and cost up to a second before the
    # window even opened. Just open, then self-heal if nothing maps.
    eww open dashboard --screen "$idx" >/dev/null 2>&1

    for i in $(seq 10); do
        [ -n "$(dash_pids)" ] && break
        sleep 0.1
    done

    if [ -z "$(dash_pids)" ]; then
        # nothing mapped within a second: the daemon is wedged, restart and retry
        pkill -x eww 2>/dev/null
        sleep 0.3
        pkill -9 -x eww 2>/dev/null
        sleep 0.2
        eww open dashboard --screen "$idx" >/dev/null 2>&1
        for i in $(seq 20); do
            [ -n "$(dash_pids)" ] && break
            sleep 0.1
        done
    fi

    # eww's index order is GDK's, which need not match Hyprland's. Rather than
    # trust the mapping, check where the window actually landed and walk the
    # other indices if it guessed wrong.
    [ -n "$foc" ] || return 0
    n=$(monitor_count)
    for i in $(seq 0 $((n - 1))); do
        [ "$(dash_monitor)" = "$foc" ] && return 0
        [ "$i" = "$idx" ] && continue
        timeout 2 eww close dashboard >/dev/null 2>&1
        sleep 0.2
        eww open dashboard --screen "$i" >/dev/null 2>&1
        sleep 0.6
    done
}

case "${1:-toggle}" in
close) close_all ;;
open) open_dash ;;
toggle)
    if [ -n "$(dash_pids)" ]; then
        # Open on another monitor: treat the toggle as "bring it here" rather
        # than a close, so it does not take two presses to move it.
        cur=$(dash_monitor)
        foc=$(focused_monitor)
        close_all
        if [ -n "$cur" ] && [ -n "$foc" ] && [ "$cur" != "$foc" ]; then
            open_dash
        fi
    else
        open_dash
    fi
    ;;
esac
