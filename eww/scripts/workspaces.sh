#!/usr/bin/env bash
# listen: emit workspace pill state once, then re-emit on Hyprland socket2
# events (push: no polling)

emit() {
    hyprctl -j workspaces 2>/dev/null | jq -c --argjson act \
        "$(hyprctl -j activeworkspace 2>/dev/null | jq '.id // 1')" \
        '[.[] | select(.id > 0) | {id, occupied: (.windows > 0), active: (.id == $act)}] | sort_by(.id)'
}

case "${1:-listen}" in
listen)
    emit
    sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    [ -S "$sock" ] || exit 0
    socat -u UNIX-CONNECT:"$sock" - 2>/dev/null | while read -r ev; do
        case "$ev" in
        workspace*|createworkspace*|destroyworkspace*|focusedmon*|openwindow*|closewindow*|movewindow*) emit ;;
        esac
    done
    ;;
once) emit ;;
esac
