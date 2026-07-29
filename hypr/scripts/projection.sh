#!/usr/bin/env bash
# Windows-style projection manager (the Win+P equivalent): extend, laptop only,
# second screen only, duplicate. Bound to SUPER + CTRL + P via programs.lua.
#
# Monitors are applied through this fork's Lua API, `hl.monitor{...}`, rather
# than `hyprctl keyword monitor "..."` — keyword exists but expects the classic
# conf syntax this Lua-config build does not use. Valid hl.monitor fields
# (probed): output, mode, position, scale, disabled, mirror, transform, vrr,
# bitdepth. `disabled` is a boolean; the rest are strings.

set -u

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/projection-state"
RASI="$HOME/.config/rofi/projection.rasi"

notify() { notify-send "Display" "$1" 2>/dev/null; }

# --- discovery --------------------------------------------------------------
# Read DRM, NOT `hyprctl monitors`: an output disabled via hl.monitor{disabled=
# true} disappears from hyprctl's list entirely, so using that as the source of
# truth would make a disabled monitor impossible to find and re-enable. DRM
# keeps reporting it as connected regardless of compositor state.

connected_outputs() {
    local s name
    for s in /sys/class/drm/card*-*/status; do
        [ -r "$s" ] || continue
        [ "$(cat "$s")" = "connected" ] || continue
        name=$(basename "$(dirname "$s")")
        printf '%s\n' "${name#card*-}"
    done | sort -u
}

internal_output() { connected_outputs | grep -m1 '^eDP' || true; }
external_outputs() { connected_outputs | grep -v '^eDP' || true; }

# --- geometry memory --------------------------------------------------------
# Re-enabling a monitor has to put it back where it was. Snapshot position and
# scale while the outputs are still active, so a later enable can restore them
# instead of guessing. Mode is deliberately not restored - a stored refresh rate
# can round to a value the output does not actually advertise, and "preferred"
# is right in every case here.

save_state() {
    local tmp
    command -v jq >/dev/null 2>&1 || return 0
    tmp=$(mktemp "${STATE_FILE}.XXXXXX") || return 0
    if hyprctl -j monitors 2>/dev/null |
        jq -r '.[] | select(.disabled | not) | "\(.name)|\(.x),\(.y)|\(.scale)"' >"$tmp" 2>/dev/null &&
        [ -s "$tmp" ]; then
        mv -f "$tmp" "$STATE_FILE"
    else
        rm -f "$tmp"
    fi
}

# echoes "position|scale" for $1, empty if unknown
state_for() {
    [ -f "$STATE_FILE" ] || return 0
    awk -F'|' -v o="$1" '$1 == o { print $2 "|" $3; exit }' "$STATE_FILE"
}

# --- applying ---------------------------------------------------------------

apply() { hyprctl eval "hl.monitor({$1})" >/dev/null 2>&1; }

enable_output() {
    local st pos scale
    st=$(state_for "$1")
    pos=${st%%|*}
    scale=${st##*|}
    [ -n "$pos" ] || pos="auto"
    [ -n "$scale" ] || scale="auto"
    # mirror='' clears any mirroring left over from Duplicate.
    apply "output='$1', disabled=false, mode='preferred', position='$pos', scale='$scale', mirror=''"
}

disable_output() { apply "output='$1', disabled=true"; }

# Last line of defence: never leave the session with nothing lit. If a switch
# somehow blanked every output, fall back to the config, which re-enables them.
ensure_display() {
    local n
    sleep 0.4
    n=$(hyprctl -j monitors 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
    if [ "${n:-0}" -lt 1 ]; then
        hyprctl reload >/dev/null 2>&1
        notify "No active output after switching - reloaded config"
        return 1
    fi
    return 0
}

require_external() {
    if [ -z "$(external_outputs)" ]; then
        notify "No second display connected"
        return 1
    fi
}

# --- modes ------------------------------------------------------------------
# Every mode enables its target BEFORE disabling anything, so there is never a
# moment with zero active outputs.

mode_extend() {
    require_external || return 1
    save_state
    local o
    for o in $(connected_outputs); do enable_output "$o"; done
    ensure_display && notify "Extended"
}

mode_internal() {
    local int o
    int=$(internal_output)
    [ -n "$int" ] || {
        notify "No internal display found"
        return 1
    }
    save_state
    enable_output "$int"
    for o in $(external_outputs); do disable_output "$o"; done
    ensure_display && notify "Laptop screen only"
}

mode_external() {
    require_external || return 1
    local int o
    int=$(internal_output)
    save_state
    for o in $(external_outputs); do enable_output "$o"; done
    [ -n "$int" ] && disable_output "$int"
    ensure_display && notify "Second screen only"
}

mode_duplicate() {
    require_external || return 1
    local int o
    int=$(internal_output)
    [ -n "$int" ] || {
        notify "No internal display to mirror"
        return 1
    }
    save_state
    enable_output "$int"
    for o in $(external_outputs); do
        apply "output='$o', disabled=false, mirror='$int'"
    done
    ensure_display && notify "Duplicated"
}

# --- menu -------------------------------------------------------------------

menu() {
    local options choice
    options=(
        "󰍺  Extend"
        "󰌢  Laptop screen only"
        "󰍹  Second screen only"
        "󰆏  Duplicate"
    )
    choice=$(printf '%s\n' "${options[@]}" |
        rofi -dmenu -i -p "󰍹 " -config "$RASI") || exit 0

    case "${choice}" in
    *Extend) mode_extend ;;
    *"Laptop screen only") mode_internal ;;
    *"Second screen only") mode_external ;;
    *Duplicate) mode_duplicate ;;
    esac
}

case "${1:-menu}" in
menu) menu ;;
extend) mode_extend ;;
internal) mode_internal ;;
external) mode_external ;;
duplicate) mode_duplicate ;;
list)
    printf 'internal: %s\n' "$(internal_output)"
    printf 'external: %s\n' "$(external_outputs | tr '\n' ' ')"
    ;;
*)
    echo "usage: projection.sh [menu|extend|internal|external|duplicate|list]" >&2
    exit 1
    ;;
esac
