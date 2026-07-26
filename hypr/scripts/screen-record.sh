#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Videos/recordings"
mkdir -p "$DIR"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    sleep 0.5
    FILE=$(ls -t "$DIR" | head -1)
    notify-send "Recording Stopped" "Saved to $DIR/$FILE" -t 2000
    exit 0
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
    notify-send "Screen Recorder" "wf-recorder is not installed:\nsudo pacman -S wf-recorder" -u critical
    exit 1
fi

mode_options=(
    "󰍹  Full screen"
    "󰖯  Window"
    "󰩭  Region"
)

audio_options=(
    "󰝟  Silent"
    "󰍬  Microphone"
    "󰓃  Speakers"
)

while true; do
    mode=$(printf '%s\n' "${mode_options[@]}" |
        rofi -dmenu -i -p "󰑋 " -config ~/.config/rofi/powermenu.rasi) || exit 0
    audio=$(printf '%s\n' "${audio_options[@]}" |
        rofi -dmenu -i -p "󰑋 " -config ~/.config/rofi/powermenu.rasi) && break
done

FILE="$DIR/Recording-$(date +%F_%H-%M-%S).mp4"
ARGS=(-f "$FILE")

case "${mode}" in
*"Full screen")
    MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    [ -n "$MONITOR" ] && ARGS+=(-o "$MONITOR")
    ;;
*Window)
    GEOM=$(hyprctl clients -j |
        jq -r --argjson ws "$(hyprctl monitors -j | jq '[.[].activeWorkspace.id]')" \
            '.[] | select(.mapped and (.workspace.id as $id | $ws | index($id))) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' |
        slurp -r) || exit 0
    ARGS+=(-g "$GEOM")
    ;;
*Region)
    GEOM=$(slurp) || exit 0
    ARGS+=(-g "$GEOM")
    ;;
esac

case "${audio}" in
*Microphone)
    SOURCE=$(pactl get-default-source)
    ARGS+=(--audio="$SOURCE")
    ;;
*Speakers)
    SINK=$(pactl get-default-sink)
    ARGS+=(--audio="$SINK.monitor")
    ;;
esac

notify-send "Recording Started" "${mode#* } · ${audio#* } — SUPER+SHIFT+G to stop" -t 1500
exec wf-recorder "${ARGS[@]}"
