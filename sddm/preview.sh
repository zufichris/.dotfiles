#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

VIDEOS_DIR="$HOME/Pictures/wallpapers/videos"
if [ -d "${VIDEOS_DIR}" ]; then
    for v in "${VIDEOS_DIR}"/*.mp4 "${VIDEOS_DIR}"/*.webm "${VIDEOS_DIR}"/*.mkv "${VIDEOS_DIR}"/*.mov; do
        [ -e "${v}" ] || continue
        ln -sf "${v}" "${SCRIPT_DIR}/backgrounds/$(basename "${v}")"
    done
fi

echo "Rotating background..."
bash "${SCRIPT_DIR}/scripts/rotate-background.sh"

if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    echo "Wayland session detected. Using QT_QPA_PLATFORM=wayland"
    PLATFORM="wayland"
else
    echo "X11 session detected. Using QT_QPA_PLATFORM=xcb"
    PLATFORM="xcb"
fi

QT_QPA_PLATFORM="${PLATFORM}" sddm-greeter-qt6 --test-mode --theme "${SCRIPT_DIR}"
