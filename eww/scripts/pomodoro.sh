#!/usr/bin/env bash
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-pomodoro"
SESSIONS="${XDG_CACHE_HOME:-$HOME/.cache}/eww-pomodoro-sessions"
DND_MARK="${XDG_CACHE_HOME:-$HOME/.cache}/eww-pomodoro-dnd"
FOCUS="${POMO_FOCUS:-1500}"
BREAK="${POMO_BREAK:-300}"

now() { date +%s; }

dur_of() { [ "$1" = "break" ] && echo "$BREAK" || echo "$FOCUS"; }

sessions_get() {
    local d n
    [ -f "$SESSIONS" ] && IFS=: read -r d n <"$SESSIONS"
    [ "$d" = "$(date +%F)" ] && echo "${n:-0}" || echo 0
}

sessions_inc() { echo "$(date +%F):$(($(sessions_get) + 1))" >"$SESSIONS"; }

# focus mode: DND while a focus session runs; the marker file makes sure we
# only ever undo DND that we ourselves enabled
dnd_on() { swaync-client -dn >/dev/null 2>&1 && touch "$DND_MARK"; }
dnd_off() {
    if [ -f "$DND_MARK" ]; then
        swaync-client -df >/dev/null 2>&1
        rm -f "$DND_MARK"
    fi
}

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
        [ "$phase" = "focus" ] && dnd_off
        ;;
    pause:*)
        phase=${s#pause:}; phase=${phase%%:*}
        rem=${s##*:}
        echo "run:$phase:$(($(now) + rem))" >"$STATE"
        [ "$phase" = "focus" ] && dnd_on
        ;;
    *)
        echo "run:focus:$(($(now) + FOCUS))" >"$STATE"
        dnd_on
        ;;
    esac
    ;;
phase)
    p="$2"
    case "$p" in focus | break) ;; *) exit 1 ;; esac
    case "$(cat "$STATE" 2>/dev/null)" in
    run:*) ;; # ignore while running
    *) echo "pause:$p:$(dur_of "$p")" >"$STATE" ;;
    esac
    ;;
reset)
    rm -f "$STATE"
    dnd_off
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
                sessions_inc
                dnd_off
                phase="break"
                rem=$BREAK
                echo "run:break:$(($(now) + BREAK))" >"$STATE"
                notify-send "Pomodoro" "Focus done, take a ${BREAK}s breather" -u critical 2>/dev/null
            else
                rm -f "$STATE"
                phase="focus"
                rem=$FOCUS
                running=false
                notify-send "Pomodoro" "Break over, ready for the next focus round" 2>/dev/null
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
    printf '{"time":"%02d:%02d","perc":%d,"running":%s,"phase":"%s","sessions":%d}\n' \
        $((rem / 60)) $((rem % 60)) "$perc" "$running" "$phase" "$(sessions_get)"
    ;;
esac
