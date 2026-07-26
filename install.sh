#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.config/dotfiles-backup-$(date +%Y%m%d%H%M%S)"

CONFIGS=(
  "hypr"
  "kitty"
  "matugen"
  "rofi"
  "swaync"
  "waybar"
  "wlogout"
  "fastfetch"
  "eww"
  "zsh"
  "gtk-3.0"
  "gtk-4.0"
  "Thunar"
  "spotify-player"
  "satty"
  "qt5ct"
  "qt6ct"
  "wpaperd"
  "zellij"
  "btop"
  "nvim"
)

SDDM_DIR="${DOTFILES_DIR}/sddm"

# shellcheck disable=SC2034
declare -A DESCRIPTIONS=(
  ["hypr"]="Hyprland WM config"
  ["kitty"]="Kitty terminal"
  ["matugen"]="Matugen dynamic theming"
  ["rofi"]="Rofi launcher + clipboard"
  ["swaync"]="Sway Notification Center"
  ["waybar"]="Waybar status bar"
  ["wlogout"]="Wlogout power menu"
  ["fastfetch"]="Fastfetch with image logo"
  ["eww"]="Eww stats dashboard"
  ["zsh"]="ZSH wallpaper utility"
  ["gtk-3.0"]="GTK3 dark theme + matugen colors"
  ["gtk-4.0"]="GTK4 dark theme + matugen colors"
  ["Thunar"]="Thunar custom actions"
  ["spotify-player"]="Spotify TUI (needs Premium)"
  ["satty"]="Screenshot annotator"
  ["qt5ct"]="Qt5 theming (matugen palette)"
  ["qt6ct"]="Qt6 theming (matugen palette)"
  ["wpaperd"]="Wpaperd wallpaper rotation"
  ["zellij"]="Zellij terminal multiplexer"
  ["btop"]="Btop system monitor"
  ["nvim"]="Neovim (lazy.nvim setup)"
)

# shellcheck disable=SC2034
declare -A PACKAGES=(
  ["hypr"]="hyprland hyprlock hypridle hyprsunset hyprpicker hyprpolkitagent xdg-desktop-portal-hyprland kitty waybar wlogout rofi swaync cliphist wl-clipboard brave-bin grim slurp satty wl-screenrec brightnessctl wireplumber pipewire pipewire-pulse playerctl imagemagick ffmpeg jq lua libnotify udiskie bibata-cursor-theme wpaperd mpv mpvpaper obs-studio v4l2loopback-dkms inter-font cantarell-fonts adwaita-fonts ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts noto-fonts-emoji"
  ["kitty"]="kitty ttf-jetbrains-mono-nerd"
  ["matugen"]="matugen imagemagick python"
  ["rofi"]="rofi cliphist wl-clipboard"
  ["swaync"]="swaync hyprpicker galculator libnotify"
  ["waybar"]="waybar swaync network-manager-applet blueman pavucontrol pipewire-pulse obsidian onlyoffice-bin neovim spotify-player"
  ["wlogout"]="wlogout"
  ["fastfetch"]="fastfetch"
  ["eww"]="eww playerctl brightnessctl jq curl pacman-contrib networkmanager bluez bluez-utils imagemagick"
  ["zsh"]="zsh wpaperd matugen"
  ["gtk-3.0"]="papirus-icon-theme adwaita-fonts"
  ["gtk-4.0"]="papirus-icon-theme adwaita-fonts"
  ["Thunar"]="thunar tumbler ffmpegthumbnailer gvfs gvfs-mtp thunar-volman thunar-archive-plugin xarchiver yad kitty udiskie"
  ["spotify-player"]="spotify-player"
  ["satty"]="satty grim slurp"
  ["qt5ct"]="qt5ct qt5-wayland"
  ["qt6ct"]="qt6ct qt6-wayland"
  ["wpaperd"]="wpaperd"
  ["zellij"]="zellij"
  ["btop"]="btop"
  ["nvim"]="neovim"
)

SDDM_PACKAGES="sddm qt6-5compat qt6-multimedia-ffmpeg qt6-svg"

HOME_PACKAGES="zsh lsd bat fzf neovim git"

# Files deployed outside ~/.config: repo-relative source → absolute destination.
declare -A HOME_FILES=(
  ["home/zshrc"]="${HOME}/.zshrc"
  ["home/gitconfig"]="${HOME}/.gitconfig"
  ["home/mimeapps.list"]="${HOME}/.config/mimeapps.list"
)

backup_existing() {
  local target="${CONFIG_DIR}/${1}"
  if [ -e "${target}" ]; then
    mkdir -p "${BACKUP_DIR}"
    cp -r "${target}" "${BACKUP_DIR}/${1}"
    echo "  ✓ backed up existing ${1}"
  fi
}

install_config() {
  local config="$1"
  local src="${DOTFILES_DIR}/${config}"
  local dst="${CONFIG_DIR}/${config}"

  backup_existing "${config}"
  rm -rf "${dst}"
  cp -r "${src}" "${dst}"
  echo "  ✓ installed ${config}"
}

append_zsh_source() {
  local marker="# dotfiles zsh utilities"
  local source_line='if [ -f ~/.config/zsh/wallpaper.zsh ]; then source ~/.config/zsh/wallpaper.zsh; fi'

  if [ -f "${HOME}/.zshrc" ]; then
    if ! grep -qF "${source_line}" "${HOME}/.zshrc"; then
      echo "" >> "${HOME}/.zshrc"
      echo "${marker}" >> "${HOME}/.zshrc"
      echo "${source_line}" >> "${HOME}/.zshrc"
      echo "  ✓ added zsh/wallpaper.zsh source to ~/.zshrc"
    else
      echo "  • zsh/wallpaper.zsh already sourced in ~/.zshrc"
    fi
  else
    echo "  ! ~/.zshrc not found; add this manually:"
    echo "    ${source_line}"
  fi
}

package_manager() {
  if command -v paru >/dev/null 2>&1; then
    echo "paru"
  elif command -v yay >/dev/null 2>&1; then
    echo "yay"
  else
    echo "pacman"
  fi
}

install_packages() {
  local pkgs="$1"
  local missing=()

  for pkg in ${pkgs}; do
    if ! pacman -Qi "${pkg}" >/dev/null 2>&1; then
      missing+=("${pkg}")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "  • all required packages already installed"
    return 0
  fi

  echo "  → installing: ${missing[*]}"

  local pm
  pm="$(package_manager)"

  case "${pm}" in
    paru)
      paru -S --needed --noconfirm "${missing[@]}" || echo "  ! package install failed for ${config}"
      ;;
    yay)
      yay -S --needed --noconfirm "${missing[@]}" || echo "  ! package install failed for ${config}"
      ;;
    pacman)
      echo "  ! Some packages may be in the AUR. Install paru/yay for AUR support."
      sudo pacman -S --needed --noconfirm "${missing[@]}" || echo "  ! package install failed for ${config}"
      ;;
  esac
}

select_configs() {
  local options=()
  for config in "${CONFIGS[@]}"; do
    options+=("${config} — ${DESCRIPTIONS[${config}]}")
  done

  local -a checked
  checkbox_menu options checked "Select configs to install"

  SELECTED=()
  for i in "${!CONFIGS[@]}"; do
    if [ "${checked[${i}]}" -eq 1 ]; then
      SELECTED+=("${CONFIGS[${i}]}")
    fi
  done
}

checkbox_menu() {
  local -n _options=$1
  local -n _checked=$2
  local _title=$3
  local cursor=0

  _checked=()
  for ((i = 0; i < ${#_options[@]}; i++)); do
    _checked[i]=0
  done

  tput civis 2>/dev/null || true
  tput smcup 2>/dev/null || true

  while true; do
    clear 2>/dev/null || printf '\033[2J\033[H'
    echo "${_title}"
    echo "↑/↓ navigate · Space toggle · Enter confirm · a toggle all"
    echo ""

    for ((i = 0; i < ${#_options[@]}; i++)); do
      local marker="[ ]"
      [ "${_checked[${i}]}" -eq 1 ] && marker="[x]"
      if [ "${i}" -eq "${cursor}" ]; then
        printf " [7m %s %s [0m\n" "${marker}" "${_options[${i}]}"
      else
        printf "   %s %s\n" "${marker}" "${_options[${i}]}"
      fi
    done

    local key seq
    IFS= read -rs -n1 key

    if [ "${key}" = $'\e' ]; then
      IFS= read -rs -n2 seq
      case "${seq}" in
        '[A' | 'OA')
          if [ "${cursor}" -gt 0 ]; then
            cursor=$((cursor - 1))
          fi
          ;;
        '[B' | 'OB')
          if [ "${cursor}" -lt $((${#_options[@]} - 1)) ]; then
            cursor=$((cursor + 1))
          fi
          ;;
      esac
    elif [ "${key}" = " " ]; then
      _checked[cursor]=$((1 - _checked[cursor]))
    elif [ "${key}" = "a" ] || [ "${key}" = "A" ]; then
      local all_on=1
      for ((i = 0; i < ${#_checked[@]}; i++)); do
        if [ "${_checked[${i}]}" -eq 0 ]; then
          all_on=0
          break
        fi
      done
      for ((i = 0; i < ${#_checked[@]}; i++)); do
        _checked[i]=$((1 - all_on))
      done
    elif [ -z "${key}" ]; then
      break
    fi
  done

  tput rmcup 2>/dev/null || true
  tput cnorm 2>/dev/null || true
}

WITH_SDDM=1
WITH_BACKLIGHT=1
WITH_HOME=1
SELECT_MODE=0

for arg in "$@"; do
  case "${arg}" in
    --select) SELECT_MODE=1 ;;
    --no-sddm) WITH_SDDM=0 ;;
    --no-backlight) WITH_BACKLIGHT=0 ;;
    --no-home) WITH_HOME=0 ;;
    *)
      echo "unknown option: ${arg}" >&2
      echo "usage: ./install.sh [--select] [--no-sddm] [--no-backlight] [--no-home]" >&2
      exit 1
      ;;
  esac
done

echo "Dotfiles installer"
echo "=================="
echo ""

if [ "${SELECT_MODE}" -eq 1 ]; then
  select_configs
else
  SELECTED=("${CONFIGS[@]}")
fi

if [ "${#SELECTED[@]}" -eq 0 ]; then
  echo "No configs selected. Exiting."
  exit 0
fi

echo "Installing configs:"
for config in "${SELECTED[@]}"; do
  echo "  - ${config}"
done

mkdir -p "${CONFIG_DIR}"

for config in "${SELECTED[@]}"; do
  echo ""
  echo "[${config}]"

  install_packages "${PACKAGES[${config}]}"

  case "${config}" in
    zsh)
      install_config "${config}"
      append_zsh_source
      if [ -d "${HOME}/.oh-my-zsh" ]; then
        mkdir -p "${HOME}/.oh-my-zsh/custom/themes"
        cp "${DOTFILES_DIR}/zsh/glass.zsh-theme" "${HOME}/.oh-my-zsh/custom/themes/"
        echo '  ✓ installed glass.zsh-theme (set ZSH_THEME="glass" in ~/.zshrc)'
      fi
      ;;
    *)
      install_config "${config}"
      ;;
  esac
done

echo ""
if [ "${WITH_HOME}" -eq 1 ]; then
  echo "[home] deploying home dotfiles"
  install_packages "${HOME_PACKAGES}"

  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh" \
      || echo "  ! oh-my-zsh clone failed; ~/.zshrc expects it at ~/.oh-my-zsh"
  fi
  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/${plugin}" ]; then
      git clone --depth 1 "https://github.com/zsh-users/${plugin}.git" \
        "${HOME}/.oh-my-zsh/custom/plugins/${plugin}" \
        || echo "  ! ${plugin} clone failed"
    fi
  done

  for src in "${!HOME_FILES[@]}"; do
    dst="${HOME_FILES[${src}]}"
    if [ -f "${dst}" ] && ! cmp -s "${DOTFILES_DIR}/${src}" "${dst}"; then
      mkdir -p "${BACKUP_DIR}/home"
      cp "${dst}" "${BACKUP_DIR}/home/$(basename "${src}")"
    fi
    install -m 644 "${DOTFILES_DIR}/${src}" "${dst}"
    echo "  ✓ installed ${dst}"
  done
else
  echo "  • skipped home dotfiles"
fi

echo ""
if [ "${WITH_SDDM}" -eq 1 ] && [ -d "${SDDM_DIR}" ]; then
  echo "[sddm] installing theme (sudo)"
  # shellcheck disable=SC2086
  sudo pacman -S --needed --noconfirm ${SDDM_PACKAGES} || true
  sudo "${SDDM_DIR}/install.sh"
else
  echo "  • skipped SDDM theme"
fi

echo ""
if [ "${WITH_BACKLIGHT}" -eq 1 ]; then
  echo "[backlight] installing udev rule (sudo)"
  sudo install -m 644 "${DOTFILES_DIR}/swaync/90-backlight.rules" /etc/udev/rules.d/90-backlight.rules
  sudo usermod -aG video "${USER}"
  sudo udevadm control --reload-rules
  sudo udevadm trigger -s backlight
  echo "  ✓ backlight rule installed (log out and back in for the video group to apply)"
else
  echo "  • skipped backlight rule"
fi

echo ""
echo "Installation complete."
if [ -d "${BACKUP_DIR}" ]; then
  echo "Backups saved to: ${BACKUP_DIR}"
fi
echo ""
echo "Next steps:"
echo "  - Review README.md files in each config for details."
echo "  - Log out and back in (or start Hyprland) to apply all changes."
