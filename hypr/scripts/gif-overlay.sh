#!/usr/bin/env bash
# gif-overlay.sh: float a looping gif (or any video) on top of everything.
# The window rule "gif-overlay" in hyprland/rules.lua makes it float, pin,
# and strip decorations. Move it with SUPER+LMB drag, resize with SUPER+RMB.
#
# usage: gif-overlay.sh                        open the picker
#        gif-overlay.sh <file> [max-size-px]   launch an overlay (default 400px)
#        gif-overlay.sh kill                   close all overlays
#
# The picker is a rofi window laid out like a webpage: a nav bar on top
# (search entry + small "close all" / "max gifs" buttons, done as rofi
# script-mode tabs) and the gif grid as the body. Max simultaneous overlays
# persists in ~/.config/hypr/gif-overlay.conf; launching past the cap
# closes the oldest overlay first.

set -euo pipefail

APP_ID="gif-overlay"
SEARCH_DIRS=("$HOME/Pictures/gifs")
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/gif-overlay.conf"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/gif-overlay-thumbs"
SELF="$(realpath "$0")"

get_max() {
	local m
	m=$(grep -om1 'max_gifs=[0-9]*' "$CONF" 2>/dev/null | cut -d= -f2)
	echo "${m:-3}"
}

set_max() {
	mkdir -p "$(dirname "$CONF")"
	echo "max_gifs=$1" >"$CONF"
}

running_count() {
	pgrep -fc "wayland-app-id=$APP_ID" || true
}

enforce_max() {
	local max count
	max=$(get_max)
	count=$(running_count)
	while ((count >= max)); do
		pkill -o -f "wayland-app-id=$APP_ID" || break
		((count--))
	done
}

# echoes 0xRRGGBB of the gif's solid background color, or nothing when
# there is no confident solid background to key out. conf overrides:
# colorkey=off disables, colorkey=0xRRGGBB forces a color, default auto.
detect_key_color() {
	local mode tmp w h c1 c2
	mode=$(grep -om1 'colorkey=[a-zA-Z0-9#x]*' "$CONF" 2>/dev/null | cut -d= -f2)
	mode="${mode:-auto}"
	case "$mode" in
	off) return 0 ;;
	auto) ;;
	*)
		echo "$mode"
		return 0
		;;
	esac
	mkdir -p "$THUMB_DIR"
	tmp="$THUMB_DIR/.keyprobe.png"
	ffmpeg -y -loglevel quiet -i "$1" -frames:v 1 -vf format=rgba "$tmp" || return 0
	w=$(magick identify -format '%w' "$tmp") || return 0
	h=$(magick identify -format '%h' "$tmp") || return 0
	c1=$(magick "$tmp" -format "%[hex:u.p{1,1}]" info:)
	c2=$(magick "$tmp" -format "%[hex:u.p{$((w - 2)),$((h - 2))}]" info:)
	rm -f "$tmp"
	[[ ${#c1} -ge 6 && ${#c2} -ge 6 ]] || return 0
	# already transparent -> nothing to key
	if [[ ${#c1} -eq 8 ]] && (($(printf '%d' "0x${c1:6:2}") < 240)); then
		return 0
	fi
	local dr dg db
	dr=$((16#${c1:0:2} - 16#${c2:0:2})) dr=${dr#-}
	dg=$((16#${c1:2:2} - 16#${c2:2:2})) dg=${dg#-}
	db=$((16#${c1:4:2} - 16#${c2:4:2})) db=${db#-}
	((dr <= 24 && dg <= 24 && db <= 24)) || return 0
	echo "0x${c1:0:6}"
}

find_gifs() {
	find "${SEARCH_DIRS[@]}" -type f \( -iname '*.gif' -o -iname '*.webm' -o -iname '*.webp' \) 2>/dev/null | awk '!seen[$0]++'
}

# rofi script-mode rows: label + thumbnail icon + full path stashed in info
gif_rows() {
	local f thumb
	while IFS= read -r f; do
		thumb="$THUMB_DIR/${f//\//_}.png"
		[[ -f "$thumb" ]] || thumb="$f"
		printf '%s\000icon\037%s\037info\037%s\n' "$(basename "$f")" "$thumb" "$f"
	done < <(find_gifs)
}

launch_overlay() {
	enforce_max
	local key
	key=$(detect_key_color "$1")
	local -a vf=()
	# crop 1px edges first (gif border pixels often miss the key color);
	# the keyed background leaves the edges fully transparent, so no extra
	# padding: a transparent pad renders as a black border in mpv; green/blue
	# screens additionally get a despill pass to clean edge fringing
	if [[ -n "$key" ]]; then
		local r g b despill="" sim=0.12 blend=0.05
		r=$((16#${key:2:2})) g=$((16#${key:4:2})) b=$((16#${key:6:2}))
		((g > r + 40 && g > b + 40)) && despill=",despill=type=green"
		((b > r + 40 && b > g + 40)) && despill=",despill=type=blue"
		# chroma screens sit far from subject colors, so key them loosely;
		# dark/neutral backgrounds stay tight to protect dark clothing
		[[ -n "$despill" ]] && sim=0.25 blend=0.1
		vf=("--vf=lavfi=[crop=iw-2:ih-2:1:1,colorkey=color=${key}:similarity=${sim}:blend=${blend}${despill}]")
	fi
	# panscan=1.0 fills the window by cropping instead of letterboxing:
	# sub-pixel letterbox margins render as an opaque black right/bottom
	# line under fractional scaling even with background=none.
	# mpv's default bindings map the wheel to volume (pointless, audio is
	# off): replace them wholesale with scroll-to-zoom. mpv cannot resize
	# its own wayland window, so the wheel shells back into this script's
	# `zoom` subcommand which resizes through the compositor.
	local input_conf="${XDG_CACHE_HOME:-$HOME/.cache}/gif-overlay-input.conf"
	cat >"$input_conf" <<-EOF
		WHEEL_UP    run "$SELF" zoom in \${pid}
		WHEEL_DOWN  run "$SELF" zoom out \${pid}
		WHEEL_LEFT  ignore
		WHEEL_RIGHT ignore
	EOF
	setsid -f mpv \
		--wayland-app-id="$APP_ID" \
		--title="$APP_ID" \
		--loop-file=inf \
		--no-audio \
		--no-osc \
		--no-osd-bar \
		--osd-level=0 \
		--input-default-bindings=no \
		--input-conf="$input_conf" \
		--background=none \
		--panscan=1.0 \
		--autofit="${2:-400}x${2:-400}" \
		"${vf[@]}" \
		"$1" &>/dev/null
}

# selections arrive here from every mode: gif rows carry the path in
# ROFI_INFO, the close-confirm row a sentinel; max-gifs rows are bare numbers
handle_selection() {
	if [[ "${ROFI_INFO:-}" == "CLOSE_ALL" ]]; then
		pkill -f "wayland-app-id=$APP_ID" || true
		gif_rows
		return
	fi
	if [[ -n "${ROFI_INFO:-}" && -f "$ROFI_INFO" ]]; then
		launch_overlay "$ROFI_INFO"
		exit 0 # no output -> rofi closes
	fi
	if [[ "${1:-}" =~ ^[0-9]+$ ]] && (($1 >= 1)); then
		set_max "$1"
	fi
	gif_rows
}

case "${1:-menu}" in
kill)
	pkill -f "wayland-app-id=$APP_ID" || true
	;;

# invoked from mpv's input.conf `run` binding, which passes its own pid
# (mpv spawns run commands through an intermediate, so $PPID is useless);
# skip (rather than clamp) out-of-range sizes to keep the window's
# aspect ratio intact
zoom)
	factor=1.15
	[[ "${2:-in}" == "out" ]] && factor=0.87
	pid="${3:-0}"
	[[ "$pid" =~ ^[0-9]+$ ]] || exit 1
	hyprctl eval "
		local t
		for _, w in ipairs(hl.get_windows()) do
			if w.pid == $pid then t = w end
		end
		if t then
			local nx = math.floor(t.size.x * $factor + 0.5)
			local ny = math.floor(t.size.y * $factor + 0.5)
			if nx >= 60 and ny >= 60 and nx <= 2400 and ny <= 2400 then
				hl.dispatch(hl.dsp.focus({ window = t }))
				hl.dispatch(hl.dsp.window.resize({ x = nx, y = ny }))
			end
		end" >/dev/null
	;;

mode-gifs)
	if [[ "${ROFI_RETV:-0}" == "1" ]]; then
		handle_selection "${2:-}"
	else
		gif_rows
	fi
	;;

# no side effects on init: rofi runs every mode script once at startup,
# so the kill only happens when the confirm row is actually selected
mode-close)
	if [[ "${ROFI_RETV:-0}" == "1" ]]; then
		handle_selection "${2:-}"
	else
		printf '󰆴  Close all %s running overlays\000info\037CLOSE_ALL\n' "$(running_count)"
	fi
	;;

mode-max)
	if [[ "${ROFI_RETV:-0}" == "1" ]]; then
		handle_selection "${2:-}"
	else
		seq 1 10
	fi
	;;

menu)
	# refresh first-frame preview thumbnails in the background
	mkdir -p "$THUMB_DIR"
	find_gifs | tr '\n' '\0' | xargs -0 -P "$(nproc)" -n1 bash -c '
		src="$1"
		thumb="'"$THUMB_DIR"'/${src//\//_}.png"
		[ -f "$thumb" ] && [ ! "$src" -nt "$thumb" ] && exit 0
		ffmpeg -y -loglevel quiet -i "$src" -frames:v 1 \
			-vf "scale=320:320:force_original_aspect_ratio=increase,crop=320:320" "$thumb"
	' _ >/dev/null 2>&1 &
	disown

	exec rofi -show 󰵸 \
		-modes "󰵸:$SELF mode-gifs,󰆴:$SELF mode-close,󰒓:$SELF mode-max" \
		-config ~/.config/rofi/gif-overlay.rasi
	;;

*)
	[[ -f "$1" ]] || { notify-send "gif-overlay" "no such file: $1"; exit 1; }
	launch_overlay "$1" "${2:-400}"
	;;
esac
