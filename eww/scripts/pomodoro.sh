#!/usr/bin/env bash
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-pomodoro"
FOCUS="${POMO_FOCUS:-1500}"
BREAK="${POMO_BREAK:-300}"

now() { date +%s; }

dur_of() { [ "$1" = "break" ] && echo "$BREAK" || echo "$FOCUS"; }

case "${1:-status}" in
toggle)
    s=$(cat "$STATE" 2>/dev/null)
    case "$s" in
    run:*)
        phase=${s#run:}; phase=${phase%%:*}
        end=${s##*:}
        rem=$((end - $(now)))
        [ "$rem" -lt 0 ] && rem=0
        echo "pause:$phase:$rem" >"$STATE"
        ;;
    pause:*)
        phase=${s#pause:}; phase=${phase%%:*}
        rem=${s##*:}
        echo "run:$phase:$(($(now) + rem))" >"$STATE"
        ;;
    *)
        echo "run:focus:$(($(now) + FOCUS))" >"$STATE"
        ;;
    esac
    ;;
reset)
    rm -f "$STATE"
    ;;
status)
    s=$(cat "$STATE" 2>/dev/null)
    phase="focus"
    rem=$FOCUS
    running=false
    case "$s" in
    run:*)
        phase=${s#run:}; phase=${phase%%:*}
        end=${s##*:}
        rem=$((end - $(now)))
        running=true
        if [ "$rem" -le 0 ]; then
            if [ "$phase" = "focus" ]; then
                phase="break"
                rem=$BREAK
                echo "run:break:$(($(now) + BREAK))" >"$STATE"
                notify-send "Pomodoro" "Focus done — take a ${BREAK}s breather" -u critical 2>/dev/null
            else
                rm -f "$STATE"
                phase="focus"
                rem=$FOCUS
                running=false
                notify-send "Pomodoro" "Break over — ready for the next focus round" 2>/dev/null
            fi
        fi
        ;;
    pause:*)
        phase=${s#pause:}; phase=${phase%%:*}
        rem=${s##*:}
        ;;
    esac
    total=$(dur_of "$phase")
    perc=$(((total - rem) * 100 / total))
    printf '{"time":"%02d:%02d","perc":%d,"running":%s,"phase":"%s"}\n' \
        $((rem / 60)) $((rem % 60)) "$perc" "$running" "$phase"
    ;;
esac
