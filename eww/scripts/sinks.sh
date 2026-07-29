#!/usr/bin/env bash
# Audio output picker.
# list     -> [{"id":54,"name":"Speakers","default":true}]
# set <id> -> make sink the default
case "${1:-list}" in
list)
    wpctl status 2>/dev/null | sed -n '/Sinks:/,/Sources:/p' |
        gawk 'match($0, /^[^0-9*]*(\*?)[[:space:]]*([0-9]+)\.[[:space:]]+(.+[^[:space:]])[[:space:]]+\[vol/, m) {
            gsub(/"/, "\\\"", m[3])
            printf "{\"id\":%s,\"name\":\"%s\",\"default\":%s}\n", m[2], m[3], (m[1] == "*" ? "true" : "false")
        }' | jq -cs .
    ;;
set) wpctl set-default "$2" ;;
esac
