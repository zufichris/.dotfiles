#!/usr/bin/env bash

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
PLACEHOLDER="$CACHE_DIR/eww-art-placeholder.png"
CARD="$CACHE_DIR/lock-np-card.png"
BLANK="$CACHE_DIR/lock-np-blank.png"
KEY_FILE="$CACHE_DIR/lock-np-card.key"

pango_escape() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

truncate_to() {
    local s=$1 n=$2
    if [ "${#s}" -gt "$n" ]; then
        printf '%s…' "${s:0:n}"
    else
        printf '%s' "$s"
    fi
}

resolve_art() {
    local url art
    url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    case "$url" in
    file://*) art="${url#file://}" ;;
    http*) art="$CACHE_DIR/eww-art" ;;
    *) art="$PLACEHOLDER" ;;
    esac
    [ -f "$art" ] || art="$PLACEHOLDER"
    printf '%s' "$art"
}

build_card() {
    local art=$1 key tile
    key=$(md5sum "$art" 2>/dev/null | cut -d' ' -f1)
    [ -f "$CARD" ] && [ "$key" = "$(cat "$KEY_FILE" 2>/dev/null)" ] && return 0
    tile="$CACHE_DIR/lock-np-tile.png"
    magick "$art" -resize 96x96^ -gravity center -extent 96x96 \
        \( -size 96x96 xc:black -fill white -draw 'roundrectangle 0,0,95,95,12,12' \) \
        -alpha off -compose CopyOpacity -composite "$tile" 2>/dev/null || return 1
    magick -size 380x128 xc:none \
        -fill 'rgba(255,255,255,0.10)' -draw 'roundrectangle 0.5,0.5,378.5,126.5,20,20' \
        -fill none -stroke 'rgba(255,255,255,0.15)' -strokewidth 1 \
        -draw 'roundrectangle 0.5,0.5,378.5,126.5,20,20' \
        "$tile" -geometry +16+16 -compose Over -composite "$CARD" 2>/dev/null || return 1
    rm -f "$tile"
    printf '%s' "$key" >"$KEY_FILE"
}

case "${1:-}" in
--toggle)
    playerctl play-pause 2>/dev/null
    ;;
--art)
    [ -f "$BLANK" ] || magick -size 1x1 xc:none "$BLANK" 2>/dev/null
    [ -f "$PLACEHOLDER" ] || magick -size 96x96 xc:'#14142f' "$PLACEHOLDER" 2>/dev/null
    status=$(playerctl status 2>/dev/null)
    case "$status" in
    Playing | Paused)
        if build_card "$(resolve_art)" && [ -f "$CARD" ]; then
            printf '%s\n' "$CARD"
        else
            printf '%s\n' "$BLANK"
        fi
        ;;
    *)
        printf '%s\n' "$BLANK"
        ;;
    esac
    ;;
--title)
    status=$(playerctl status 2>/dev/null)
    case "$status" in
    Playing | Paused)
        title=$(playerctl metadata title 2>/dev/null)
        icon="󰝚"
        [ "$status" = "Paused" ] && icon="󰏤"
        printf '%s  %s\n' "$icon" "$(truncate_to "${title:-…}" 28 | pango_escape)"
        ;;
    *)
        printf '\n'
        ;;
    esac
    ;;
--artist)
    status=$(playerctl status 2>/dev/null)
    case "$status" in
    Playing | Paused)
        artist=$(playerctl metadata artist 2>/dev/null)
        printf '%s\n' "$(truncate_to "${artist:-…}" 30 | pango_escape)"
        ;;
    *)
        printf '\n'
        ;;
    esac
    ;;
esac
