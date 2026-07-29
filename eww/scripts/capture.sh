#!/usr/bin/env bash
# Screen capture helpers for the dashboard.
# status      -> {"recording":bool,"elapsed":"m:ss","available":bool}
# toggle      -> start/stop a screen recording (wl-screenrec or wf-recorder)
# shot-region -> close the dashboard, then region screenshot (detached:
#                closing the dashboard can kill our eww ancestor)
DIR="$HOME/Videos/recordings"

recorder() {
    for r in wl-screenrec wf-recorder; do
        command -v "$r" >/dev/null 2>&1 && { echo "$r"; return 0; }
    done
    return 1
}

running_pid() {
    # one pgrep for both recorders; note `pgrep | head` exits 0 even with no
    # match, so test the value rather than $?
    local p
    p=$(pgrep -x '(wl-screenrec|wf-recorder)' 2>/dev/null | head -1)
    printf '%s' "$p"
}

case "${1:-status}" in
status)
    avail=false
    recorder >/dev/null && avail=true
    pid=$(running_pid)
    if [ -n "$pid" ]; then
        secs=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
        secs=${secs:-0}
        printf '{"recording":true,"elapsed":"%d:%02d","available":%s}\n' \
            $((secs / 60)) $((secs % 60)) "$avail"
    else
        printf '{"recording":false,"elapsed":"","available":%s}\n' "$avail"
    fi
    ;;
toggle)
    if [ -n "$(running_pid)" ]; then
        pkill -INT -x wl-screenrec 2>/dev/null
        pkill -INT -x wf-recorder 2>/dev/null
        notify-send "Recording stopped" "Saved to $DIR" -t 2000 2>/dev/null
        exit 0
    fi
    bin=$(recorder) || {
        notify-send "Recording unavailable" "Install wf-recorder or wl-screenrec" -t 3000 2>/dev/null
        exit 1
    }
    mkdir -p "$DIR"
    file="$DIR/Recording-$(date +%F_%H-%M-%S).mp4"
    notify-send "Recording started" "Press the record button again to stop" -t 2000 2>/dev/null
    setsid -f "$bin" -f "$file" >/dev/null 2>&1
    ;;
shot-region)
    setsid -f bash -c "\"$HOME/.config/hypr/scripts/dashboard.sh\" close; sleep 0.3; \"$HOME/.config/hypr/scripts/screenshot.sh\" region" >/dev/null 2>&1
    ;;
esac
