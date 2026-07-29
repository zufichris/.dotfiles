#!/usr/bin/env bash
# Now-playing data. Polled every 2s, so it must stay cheap: ONE playerctl call
# for every field (seven separate calls cost ~210ms), no stat/md5sum per poll,
# and the blurred-art derivative is generated in the background so a new track
# never stalls the poll.
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
ART="$CACHE_DIR/eww-art"
ART_URL_MARK="$CACHE_DIR/eww-art.url"
PLACEHOLDER="$CACHE_DIR/eww-art-placeholder.png"
BLUR_PLACEHOLDER="$CACHE_DIR/eww-art-blur-placeholder.png"
BLUR_MARK="$CACHE_DIR/eww-art-blur.current"

if [ "${1:-}" = "seek" ]; then
    len_us=$(playerctl metadata mpris:length 2>/dev/null)
    [ -n "$len_us" ] && playerctl position "$(awk -v l="$len_us" -v p="$2" 'BEGIN { printf "%.1f", l * p / 100 / 1000000 }')"
    exit 0
fi

[ -f "$PLACEHOLDER" ] || magick -size 96x96 xc:'#14142f' "$PLACEHOLDER" 2>/dev/null
[ -f "$BLUR_PLACEHOLDER" ] || magick -size 400x200 xc:'#14142f' "$BLUR_PLACEHOLDER" 2>/dev/null

IFS='|' read -r status artist title url len_us pos_us < <(
    playerctl metadata --format \
        '{{status}}|{{artist}}|{{title}}|{{mpris:artUrl}}|{{mpris:length}}|{{position}}' 2>/dev/null
)
[ -n "$status" ] || status="Stopped"

art="$PLACEHOLDER"
case "$url" in
file://*)
    # browsers rotate these temp files, so the path can already be gone
    art="${url#file://}"
    [ -f "$art" ] || art="$PLACEHOLDER"
    ;;
http*)
    if [ "$(cat "$ART_URL_MARK" 2>/dev/null)" != "$url" ]; then
        curl -sf --max-time 5 -o "$ART" "$url" && printf '%s' "$url" >"$ART_URL_MARK"
    fi
    [ -f "$ART" ] && art="$ART"
    ;;
esac

# cache key straight from the url (no stat/md5sum spawn). GTK caches CSS
# background images by path, so the filename must change when the art does.
art_blur="$BLUR_PLACEHOLDER"
if [ "$art" != "$PLACEHOLDER" ] && [ -f "$art" ]; then
    key="${url##*/}"
    key="${key//[^A-Za-z0-9._-]/}"
    blur="$CACHE_DIR/eww-art-blur-$key.png"
    if [ -f "$blur" ]; then
        art_blur="$blur"
        [ "$(cat "$BLUR_MARK" 2>/dev/null)" = "$blur" ] || printf '%s' "$blur" >"$BLUR_MARK"
    else
        # generate detached; keep showing the previous art until it lands
        setsid -f bash -c "
            find '$CACHE_DIR' -maxdepth 1 -name 'eww-art-blur-*.png' \
                 ! -name 'eww-art-blur-placeholder.png' -delete 2>/dev/null
            magick '$art' -resize 400x -gaussian-blur 0x12 -fill black -colorize 45% '$blur' 2>/dev/null
        " >/dev/null 2>&1
        prev=$(cat "$BLUR_MARK" 2>/dev/null)
        [ -n "$prev" ] && [ -f "$prev" ] && art_blur="$prev"
    fi
fi

pos_perc=0
pos_str="0:00"
len_str="0:00"
if [ -n "$len_us" ] && [ -n "$pos_us" ] && [ "$len_us" -gt 0 ] 2>/dev/null; then
    len_s=$((len_us / 1000000))
    pos_i=$((pos_us / 1000000))
    pos_perc=$((pos_i * 100 / len_s))
    printf -v pos_str '%d:%02d' $((pos_i / 60)) $((pos_i % 60))
    printf -v len_str '%d:%02d' $((len_s / 60)) $((len_s % 60))
fi

jq -cn --arg s "$status" --arg a "$artist" --arg t "$title" --arg art "$art" \
    --arg ab "$art_blur" --argjson pp "$pos_perc" --arg ps "$pos_str" --arg ls "$len_str" \
    '{status: $s, artist: $a, title: $t, art: $art, art_blur: $ab, next: "",
      pos_perc: $pp, pos_str: $ps, len_str: $ls}'
