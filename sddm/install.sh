#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
THEME_ID="zufi-sddm"
THEME_DST="/usr/share/sddm/themes/${THEME_ID}"
STAGE_DST="/usr/share/sddm/themes/.${THEME_ID}.stage"
PREVIOUS_DST="/usr/share/sddm/themes/.${THEME_ID}.previous"
SDDM_CONF="/etc/sddm.conf"
SDDM_CONF_BACK="/etc/sddm.conf.${THEME_ID}-back"

die() {
    echo "error: $*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not installed"
}

validate_theme() {
    local dir="$1"
    [ -f "${dir}/metadata.desktop" ] || die "metadata.desktop missing in ${dir}"
    [ -f "${dir}/theme.conf" ] || die "theme.conf missing in ${dir}"
    [ -f "${dir}/src/Main.qml" ] || die "src/Main.qml missing in ${dir}"
}

cleanup_stage() {
    rm -rf "${STAGE_DST}"
}

cleanup_previous() {
    rm -rf "${PREVIOUS_DST}"
}

restore_previous() {
    if [ -d "${PREVIOUS_DST}" ]; then
        rm -rf "${THEME_DST}"
        mv "${PREVIOUS_DST}" "${THEME_DST}"
        echo "restored previous theme"
    fi
}

main() {
    need_cmd sddm-greeter-qt6
    need_cmd sddm-greeter

    validate_theme "${SCRIPT_DIR}"

    echo "Installing ${THEME_ID}..."
    echo "  source: ${SCRIPT_DIR}"
    echo "  destination: ${THEME_DST}"
    echo ""

    cleanup_stage
    cleanup_previous

    mkdir -p "${STAGE_DST}"
    cp -r "${SCRIPT_DIR}"/* "${STAGE_DST}/"

    rm -f "${STAGE_DST}/install.sh" "${STAGE_DST}/preview.sh" "${STAGE_DST}/README.md" "${STAGE_DST}/LICENSE"

    local owner videos_dir
    owner="${SUDO_USER:-$USER}"
    videos_dir="$(getent passwd "${owner}" | cut -d: -f6)/Pictures/wallpapers/videos"
    if [ -d "${videos_dir}" ]; then
        local v
        for v in "${videos_dir}"/*.mp4 "${videos_dir}"/*.webm "${videos_dir}"/*.mkv "${videos_dir}"/*.mov; do
            [ -e "${v}" ] || continue
            ln -sf "${v}" "${STAGE_DST}/backgrounds/$(basename "${v}")"
        done
        echo "  linked video backgrounds from ${videos_dir}"
    fi

    echo "Rotating background..."
    bash "${STAGE_DST}/scripts/rotate-background.sh"

    validate_theme "${STAGE_DST}"

    if [ -d "${THEME_DST}" ]; then
        mv "${THEME_DST}" "${PREVIOUS_DST}"
    fi

    if ! mv "${STAGE_DST}" "${THEME_DST}"; then
        restore_previous
        die "failed to activate theme"
    fi

    validate_theme "${THEME_DST}"

    if [ -f "${SDDM_CONF}" ] && [ ! -f "${SDDM_CONF_BACK}" ]; then
        cp "${SDDM_CONF}" "${SDDM_CONF_BACK}"
    fi

    if [ -f "${SDDM_CONF}" ]; then
        if grep -q "^Current=" "${SDDM_CONF}"; then
            sed -i "s/^Current=.*/Current=${THEME_ID}/" "${SDDM_CONF}"
        else
            echo -e "\n[Theme]\nCurrent=${THEME_ID}" >> "${SDDM_CONF}"
        fi
    else
        echo -e "[Theme]\nCurrent=${THEME_ID}" > "${SDDM_CONF}"
    fi

    cleanup_previous

    if command -v systemctl >/dev/null 2>&1; then
        cp "${THEME_DST}/systemd/sddm-zufi-rotate-background.service" /etc/systemd/system/
        cp "${THEME_DST}/systemd/sddm-zufi-rotate-background.timer" /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable sddm-zufi-rotate-background.service
        systemctl enable sddm-zufi-rotate-background.timer
        echo "Enabled daily background rotation"
    fi

    echo "${THEME_ID} installed to ${THEME_DST}"
    echo "SDDM theme set to ${THEME_ID} in ${SDDM_CONF}"
    echo ""
    echo "Test safely with:"
    echo "  cd ${THEME_DST}"
    echo "  QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme ${THEME_DST}"
    echo ""
    echo "Apply with (logs you out):"
    echo "  sudo systemctl restart sddm"
}

main "$@"
