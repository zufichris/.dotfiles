#!/usr/bin/env bash
read -r mem_total mem_used swap_total swap_used < <(free -b | awk '
    /^Mem:/  { mt=$2; mu=$3 }
    /^Swap:/ { st=$2; su=$3 }
    END { print mt, mu, st, su }')

gb() { awk -v b="$1" 'BEGIN { printf "%.1f", b / 1073741824 }'; }

mem_perc=$((mem_used * 100 / mem_total))
if [ "$swap_total" -gt 0 ]; then
    swap_perc=$((swap_used * 100 / swap_total))
    swap_str="$(gb "$swap_used") GB / $(gb "$swap_total") GB"
else
    swap_perc=0
    swap_str="none"
fi

read -r disk_used disk_total disk_perc < <(df -h --output=used,size,pcent / | awk 'NR==2 { gsub("%",""); print $1, $2, $3 }')

jq -cn \
    --arg ms "$(gb "$mem_used") GB / $(gb "$mem_total") GB" --argjson mp "$mem_perc" \
    --arg ss "$swap_str" --argjson sp "$swap_perc" \
    --arg ds "${disk_used} / ${disk_total}" --argjson dp "$disk_perc" \
    '{mem_str: $ms, mem_perc: $mp, swap_str: $ss, swap_perc: $sp, disk_str: $ds, disk_perc: $dp}'
