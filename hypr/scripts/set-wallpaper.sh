#!/usr/bin/env bash

set -u

WALL="${1:-}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$CACHE_DIR/matugen_wallpaper"
FRAME_FILE="$CACHE_DIR/wallpaper_frame.jpg"

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    echo "usage: set-wallpaper.sh <image-or-video>" >&2
    exit 1
fi

is_video() {
    case "${1##*.}" in
    [Mm][Pp]4 | [Ww][Ee][Bb][Mm] | [Mm][Kk][Vv] | [Mm][Oo][Vv]) return 0 ;;
    *) return 1 ;;
    esac
}

theme_from() {
    cp -f "$1" "$CACHE_DIR/current_wallpaper"
    ~/.config/hypr/scripts/apply-theme.sh "$1"
}

if is_video "$WALL"; then
    if ! command -v mpvpaper >/dev/null 2>&1; then
        notify-send "Wallpaper" "mpvpaper is not installed — video wallpapers unavailable" 2>/dev/null
        exit 1
    fi
    pkill -x mpvpaper 2>/dev/null
    pkill -x wpaperd 2>/dev/null
    mpvpaper -o "no-audio loop-file=inf" '*' "$WALL" >/dev/null 2>&1 &
    disown
    if ffmpeg -y -ss 00:00:01.000 -i "$WALL" -vframes 1 "$FRAME_FILE" -loglevel quiet; then
        theme_from "$FRAME_FILE"
    fi
else
    pkill -x mpvpaper 2>/dev/null
    if ! pgrep -x wpaperd >/dev/null; then
        wpaperd >/dev/null 2>&1 &
        disown
        sleep 0.5
    fi
    wpaperctl set-wallpaper "$WALL" >/dev/null 2>&1
    theme_from "$WALL"
fi

printf '%s\n' "$WALL" >"$STATE_FILE"
