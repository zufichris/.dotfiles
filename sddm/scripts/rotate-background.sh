#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BG_DIR="$ROOT_DIR/backgrounds"
THEME_CONF="$ROOT_DIR/theme.conf"

if [ ! -d "$BG_DIR" ]; then
    echo "Backgrounds directory not found: $BG_DIR" >&2
    exit 1
fi

if [ ! -f "$THEME_CONF" ]; then
    echo "Theme config not found: $THEME_CONF" >&2
    exit 1
fi

avatar_dir="$(grep -E '^AvatarDir=' "$THEME_CONF" | tail -n1 | cut -d= -f2 | tr -d '"' || true)"
if [ -n "${avatar_dir}" ] && [ -d "${avatar_dir}" ]; then
    avatar="$(find -L "$avatar_dir" -maxdepth 1 -type f \( \
        -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
    \) | shuf -n1 || true)"
    if [ -n "${avatar}" ]; then
        cp -f "$avatar" "$ROOT_DIR/avatar.png"
        echo "Rotated avatar to $(basename "$avatar")"
    fi
fi

colors_file="$(grep -E '^ThemeColorsFile=' "$THEME_CONF" | tail -n1 | cut -d= -f2- | tr -d '"' || true)"
if [ -n "${colors_file}" ] && [ -f "${colors_file}" ]; then
    while IFS= read -r line; do
        case "$line" in
        [A-Za-z]*=\"*\")
            key="${line%%=*}"
            if grep -q "^${key}=" "$THEME_CONF"; then
                sed -i "s|^${key}=.*|${line}|" "$THEME_CONF"
            else
                printf '%s\n' "$line" >>"$THEME_CONF"
            fi
            ;;
        esac
    done <"${colors_file}"
    echo "Merged theme colors from ${colors_file}"
fi

auto_rotate="$(grep -E '^AutoRotateBackground=' "$THEME_CONF" | tail -n1 | cut -d= -f2 | tr -d ' "')"
if [ "${auto_rotate}" != "true" ]; then
    echo "AutoRotateBackground is not enabled; skipping rotation"
    exit 0
fi

mapfile -t files < <(find -L "$BG_DIR" -maxdepth 1 -type f \( \
    -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o \
    -iname '*.mov' -o -iname '*.m4v' -o -iname '*.avi' \
\) | sort)

if [ "${#files[@]}" -eq 0 ]; then
    mapfile -t files < <(find -L "$BG_DIR" -maxdepth 1 -type f \( \
        -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o \
        -iname '*.gif' -o -iname '*.webp' \
    \) | sort)
fi

count=${#files[@]}

if [ "$count" -eq 0 ]; then
    echo "No background files found in $BG_DIR"
    exit 0
fi

day_of_year="$(date +%j)"
index=$(( (day_of_year - 1) % count ))
selected="${files[$index]}"
relative="backgrounds/$(basename "$selected")"

if grep -q '^Background=' "$THEME_CONF"; then
    sed -i "s|^Background=.*|Background=\"$relative\"|" "$THEME_CONF"
else
    echo "Background=\"$relative\"" >> "$THEME_CONF"
fi

echo "Rotated background to $relative"
