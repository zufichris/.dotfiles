#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

lua "${SCRIPT_DIR}/keybinds-help.lua" "${SCRIPT_DIR}/.." |
	rofi -dmenu -i -markup-rows -p "󰌌 " \
		-config ~/.config/rofi/keybinds.rasi \
		>/dev/null || true
