#!/usr/bin/env bash
# Quick-capture todo tile backed by ~/notes/inbox.md ("- [ ]" lines).
# list / add <text> / check <line-no>: add and check print the fresh list
# so `eww update todo="$(todo.sh ...)"` never shows stale line numbers.
FILE="$HOME/notes/inbox.md"

list() {
    total=$(grep -c '^- \[ \]' "$FILE" 2>/dev/null)
    total=${total:-0}
    grep -n '^- \[ \]' "$FILE" 2>/dev/null | head -5 |
        jq -R -s --argjson total "$total" \
            'split("\n") | map(select(length > 0)
             | capture("^(?<line>[0-9]+):- \\[ \\] (?<text>.*)$")
             | {line: (.line | tonumber), text})
             | {items: ., total: $total}'
}

case "${1:-list}" in
list) list ;;
add)
    shift
    [ -n "$*" ] || { list; exit 0; }
    mkdir -p "$(dirname "$FILE")"
    printf -- '- [ ] %s\n' "$*" >>"$FILE"
    list
    ;;
check)
    n="$2"
    if [ -n "$n" ] && sed -n "${n}p" "$FILE" 2>/dev/null | grep -q '^- \[ \]'; then
        sed -i "${n}s/^- \[ \]/- [x]/" "$FILE"
    fi
    list
    ;;
esac
