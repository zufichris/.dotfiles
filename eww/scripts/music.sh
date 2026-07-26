#!/usr/bin/env bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
ART="$CACHE_DIR/eww-art"
ART_URL_MARK="$CACHE_DIR/eww-art.url"
PLACEHOLDER="$CACHE_DIR/eww-art-placeholder.png"

[ -f "$PLACEHOLDER" ] || magick -size 96x96 xc:'#14142f' "$PLACEHOLDER" 2>/dev/null

if [ "${1:-}" = "seek" ]; then
    len_us=$(playerctl metadata mpris:length 2>/dev/null)
    [ -n "$len_us" ] && playerctl position "$(awk -v l="$len_us" -v p="$2" 'BEGIN { printf "%.1f", l * p / 100 / 1000000 }')"
    exit 0
fi

status=$(playerctl status 2>/dev/null || echo "Stopped")
artist=$(playerctl metadata artist 2>/dev/null || true)
title=$(playerctl metadata title 2>/dev/null || true)

art="$PLACEHOLDER"
url=$(playerctl metadata mpris:artUrl 2>/dev/null || true)
if [ -n "$url" ]; then
    case "$url" in
    file://*)
        art="${url#file://}"
        ;;
    http*)
        if [ "$(cat "$ART_URL_MARK" 2>/dev/null)" != "$url" ]; then
            curl -sf --max-time 5 -o "$ART" "$url" && printf '%s' "$url" >"$ART_URL_MARK"
        fi
        [ -f "$ART" ] && art="$ART"
        ;;
    esac
fi

pos_perc=0
pos_str="0:00"
len_str="0:00"
len_us=$(playerctl metadata mpris:length 2>/dev/null)
pos_s=$(playerctl position 2>/dev/null)
if [ -n "$len_us" ] && [ -n "$pos_s" ] && [ "$len_us" -gt 0 ] 2>/dev/null; then
    len_s=$((len_us / 1000000))
    pos_i=${pos_s%.*}
    pos_perc=$((pos_i * 100 / len_s))
    pos_str=$(printf '%d:%02d' $((pos_i / 60)) $((pos_i % 60)))
    len_str=$(printf '%d:%02d' $((len_s / 60)) $((len_s % 60)))
fi

jq -cn --arg s "$status" --arg a "$artist" --arg t "$title" --arg art "$art" \
    --argjson pp "$pos_perc" --arg ps "$pos_str" --arg ls "$len_str" \
    '{status: $s, artist: $a, title: $t, art: $art, pos_perc: $pp, pos_str: $ps, len_str: $ls}'
