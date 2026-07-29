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

# wpaperd's socket exists long before it will act on commands; at cold boot it
# has taken >30s to answer. A fixed sleep loses that race, so poll instead.
wait_for_wpaperd() {
    local i
    for i in $(seq 1 120); do
        timeout 5 wpaperctl all-wallpapers >/dev/null 2>&1 && return 0
        sleep 0.5
    done
    return 1
}

# wpaperd comes up on the first file of the group regardless of what it showed
# last, so a set that silently fails leaves the wrong wallpaper up. Confirm it
# landed rather than firing and hoping.
apply_wpaperd() {
    local i
    for i in $(seq 1 10); do
        timeout 5 wpaperctl set-wallpaper "$1" >/dev/null 2>&1
        timeout 5 wpaperctl all-wallpapers 2>/dev/null | grep -Fq -- ": $1" && return 0
        sleep 0.5
    done
    return 1
}

if is_video "$WALL"; then
    if ! command -v mpvpaper >/dev/null 2>&1; then
        notify-send "Wallpaper" "mpvpaper is not installed, video wallpapers unavailable" 2>/dev/null
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
    fi
    if ! wait_for_wpaperd || ! apply_wpaperd "$WALL"; then
        notify-send "Wallpaper" "wpaperd did not accept $(basename "$WALL")" 2>/dev/null
        exit 1
    fi
    # set-wallpaper pauses the rotation timer, which would otherwise stay
    # paused for the whole session since restore sets a wallpaper at boot.
    timeout 5 wpaperctl resume-wallpaper >/dev/null 2>&1
    theme_from "$WALL"
fi

printf '%s\n' "$WALL" >"$STATE_FILE"
