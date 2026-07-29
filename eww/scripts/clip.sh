#!/usr/bin/env bash
# Clipboard history tile (cliphist).
# list       -> [{"id":"123","preview":"...","img":false}]
# copy <id>  -> restore entry to the clipboard

case "${1:-list}" in
list)
    command -v cliphist >/dev/null 2>&1 || { echo "[]"; exit 0; }
    cliphist list 2>/dev/null | head -5 |
        jq -R -s 'split("\n") | map(select(length > 0) | split("\t") as $p |
            {id: $p[0],
             preview: (($p[1] // "") | .[0:40]),
             img: (($p[1] // "") | test("\\[\\[ binary data"))})'
    ;;
copy)
    printf '%s\t\n' "$2" | cliphist decode | wl-copy
    ;;
esac
