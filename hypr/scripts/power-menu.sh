#!/usr/bin/env bash

set -euo pipefail

options=(
	"󰌾  Lock"
	"󰗽  Logout"
	"󰋊  Hibernate"
	"󰤄  Sleep"
	"󰜉  Restart"
	"⏻  Power off"
)

choice=$(printf '%s\n' "${options[@]}" |
	rofi -dmenu -i -p "⏻ " -config ~/.config/rofi/powermenu.rasi) || exit 0

case "${choice}" in
*Lock) ~/.config/hypr/scripts/lock.sh ;;
*Logout) hyprctl eval "hl.dispatch(hl.dsp.exit())" ;;
*Hibernate) systemctl hibernate ;;
*Sleep) ~/.config/hypr/scripts/lock.sh & sleep 0.5 && systemctl suspend ;;
*Restart) systemctl reboot ;;
*"Power off") systemctl poweroff ;;
esac
