#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper picker" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

mapfile -t WALLPAPERS < <(find -L "$WALLPAPER_DIR" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.mov' \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper picker" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

is_video() {
    case "${1##*.}" in
    [Mm][Pp]4 | [Ww][Ee][Bb][Mm] | [Mm][Kk][Vv] | [Mm][Oo][Vv]) return 0 ;;
    *) return 1 ;;
    esac
}

thumb_path() {
    printf '%s/%s.jpg' "$THUMB_DIR" "${1//\//_}"
}

mkdir -p "$THUMB_DIR"
printf '%s\0' "${WALLPAPERS[@]}" | xargs -0 -P "$(nproc)" -n1 bash -c '
    src="$1"
    rel="${src#'"$WALLPAPER_DIR"'/}"
    thumb="'"$THUMB_DIR"'/${rel//\//_}.jpg"
    [ -f "$thumb" ] && [ ! "$src" -nt "$thumb" ] && exit 0
    case "${src##*.}" in
    [Mm][Pp]4 | [Ww][Ee][Bb][Mm] | [Mm][Kk][Vv] | [Mm][Oo][Vv])
        frame="$thumb.frame.jpg"
        ffmpeg -y -ss 00:00:01.000 -i "$src" -vframes 1 "$frame" -loglevel quiet &&
            magick "$frame" -resize 400x400^ -gravity center -extent 400x400 "$thumb" 2>/dev/null
        rm -f "$frame"
        ;;
    *)
        magick "$src" -resize 400x400^ -gravity center -extent 400x400 "$thumb" 2>/dev/null
        ;;
    esac
' _ >/dev/null 2>&1 &
disown

SELECTION=$(for f in "${WALLPAPERS[@]}"; do
    rel="${f#"$WALLPAPER_DIR"/}"
    thumb="$(thumb_path "$rel")"
    icon="$thumb"
    label="$rel"
    if is_video "$f"; then
        label="󰕧  $rel"
        [ -f "$thumb" ] || icon=""
    else
        [ -f "$thumb" ] || icon="$f"
    fi
    if [ -n "$icon" ]; then
        printf '%s\000icon\037%s\n' "$label" "$icon"
    else
        printf '%s\n' "$label"
    fi
done | rofi -dmenu -i -p "󰸉 " -config "$HOME/.config/rofi/wallpaper.rasi")

if [ -z "$SELECTION" ]; then
    exit 0
fi

SELECTION="${SELECTION#󰕧  }"
FULL_PATH="$WALLPAPER_DIR/$SELECTION"

if [ -f "$FULL_PATH" ]; then
    if ~/.config/hypr/scripts/set-wallpaper.sh "$FULL_PATH"; then
        notify-send "Wallpaper changed" "$SELECTION" -i "$HOME/.cache/current_wallpaper"
    fi
fi
