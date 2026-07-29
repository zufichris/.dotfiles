#!/usr/bin/env bash
# Notification history for the dashboard. swaync keeps no history, so a tiny
# daemon eavesdrops org.freedesktop.Notifications on the session bus.
#   daemon -> run forever (autostarted from hyprland programs.lua)
#   listen -> deflisten source: emit current list, then follow updates
#   list   -> print current list once
#   clear  -> empty the history
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STORE="$CACHE_DIR/eww-notifs.json"        # one notification per line, newest last
STREAM="$CACHE_DIR/eww-notifs.stream"     # one full-array emission per line
LOCK="${XDG_RUNTIME_DIR:-/tmp}/eww-notif-log.lock"

glyph_for() {
    case "$(tr '[:upper:]' '[:lower:]' <<<"$1")" in
    *brave* | *firefox* | *zen* | *chromium*) echo "󰖟" ;;
    *discord* | *vesktop* | *webcord*) echo "󰙯" ;;
    *telegram*) echo "" ;;
    *spotify* | *mpd* | *music*) echo "" ;;
    *mail* | *thunderbird* | *proton*) echo "󰇮" ;;
    *pomodoro*) echo "󰄉" ;;
    *screenshot* | *satty* | *grim*) echo "󰄀" ;;
    *network*) echo "󰤨" ;;
    *blue*) echo "󰂯" ;;
    *battery* | *power*) echo "󰁹" ;;
    *wallpaper* | *matugen* | *theme*) echo "󰸉" ;;
    *) echo "󰂚" ;;
    esac
}

emit_list() {
    [ -s "$STORE" ] && jq -cs 'reverse | .[0:3]' "$STORE" || echo "[]"
}

case "${1:-daemon}" in
daemon)
    exec 9>"$LOCK"
    flock -n 9 || exit 0
    mkdir -p "$CACHE_DIR"
    touch "$STORE" "$STREAM"
    busctl --user monitor --json=short \
        --match "interface='org.freedesktop.Notifications',member='Notify'" 2>/dev/null |
        jq --unbuffered -c 'select(.type == "method_call" and .member == "Notify")
            | .payload.data | {app: (.[0] // "?"), summary: (.[3] // "")}' |
        while read -r ev; do
            app=$(jq -r '.app' <<<"$ev")
            summary=$(jq -r '.summary' <<<"$ev")
            [ -n "$summary" ] || continue
            jq -cn --arg a "$app" --arg i "$(glyph_for "$app")" --arg s "$summary" \
                --arg t "$(date +%H:%M)" '{app: $a, icon: $i, summary: $s, time: $t}' >>"$STORE"
            tail -n 10 "$STORE" >"$STORE.tmp" && mv "$STORE.tmp" "$STORE"
            emit_list >>"$STREAM"
            if [ "$(wc -l <"$STREAM")" -gt 200 ]; then
                tail -n 50 "$STREAM" >"$STREAM.tmp" && mv "$STREAM.tmp" "$STREAM"
            fi
        done
    ;;
listen)
    mkdir -p "$CACHE_DIR"
    touch "$STORE" "$STREAM"
    emit_list
    exec tail -n0 -F "$STREAM" 2>/dev/null
    ;;
list) emit_list ;;
clear)
    : >"$STORE"
    echo "[]" >>"$STREAM"
    ;;
esac
