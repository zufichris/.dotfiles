#!/usr/bin/env bash
# Pending pacman updates -> {"count":24,"pkgs":[...],"tip":"..."}
# checkupdates takes ~1.5s, so the poll only ever reads a cache file and
# refreshes it in the background when stale.
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-updates.json"
MAX_AGE=1800

refresh() {
    out=$(checkupdates 2>/dev/null)
    if [ -z "$out" ]; then
        echo '{"count":0,"pkgs":[],"tip":"System up to date"}' >"$CACHE"
    else
        jq -cn --arg out "$out" '
            ($out | split("\n") | map(select(length > 0))) as $lines |
            {count: ($lines | length),
             pkgs: ($lines | map(split(" ")[0]) | .[0:5]),
             tip: (($lines | .[0:5] | join("\n"))
                   + (if ($lines | length) > 5 then "\n… and \(($lines | length) - 5) more" else "" end))}' >"$CACHE"
    fi
}

if [ "${1:-}" = "refresh" ]; then
    refresh
    exit 0
fi

stale=true
if [ -s "$CACHE" ]; then
    age=$(($(date +%s) - $(stat -c %Y "$CACHE")))
    [ "$age" -lt "$MAX_AGE" ] && stale=false
fi
[ "$stale" = true ] && setsid -f "$0" refresh >/dev/null 2>&1

if [ -s "$CACHE" ]; then
    cat "$CACHE"
else
    echo '{"count":0,"pkgs":[],"tip":"Checking…"}'
fi
