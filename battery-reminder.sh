#!/bin/bash
set -euo pipefail

# Should match the thresholds configured in battery-guard.sh
START_THRESHOLD=55
STOP_THRESHOLD=80

# How naggy the reminder is while a condition keeps holding true.
# REPEAT_EVERY_RUNS: 0 = notify once, then stay silent until the condition
#   clears. N > 0 = notify again every N timer runs while it still holds.
#   With the timer's default 2-minute interval, 1 nags every ~2 minutes,
#   5 nags every ~10 minutes.
# MAX_REPEATS: 0 = no cap on repeats. N > 0 = stop re-notifying after N
#   repeats (still resets once the condition clears). Ignored when
#   REPEAT_EVERY_RUNS is 0.
REPEAT_EVERY_RUNS=0
MAX_REPEATS=0

BAT_CAPACITY="/sys/class/power_supply/BAT0/capacity"
STATE_HIGH="$HOME/.cache/battery-reminder-state-high"
STATE_LOW="$HOME/.cache/battery-reminder-state-low"

[ -f "$BAT_CAPACITY" ] || exit 0

CAP=$(cat "$BAT_CAPACITY")

AC_ONLINE=0
for supply in /sys/class/power_supply/*; do
    [ -f "$supply/type" ] || continue
    [ "$(cat "$supply/type")" = "Mains" ] || continue
    if [ -f "$supply/online" ] && [ "$(cat "$supply/online")" = "1" ]; then
        AC_ONLINE=1
        break
    fi
done

# Sends the notification the first time a condition becomes true, then
# repeats it according to REPEAT_EVERY_RUNS/MAX_REPEATS while it persists.
maybe_notify() {
    local state_file="$1"
    local message="$2"

    if [ ! -f "$state_file" ]; then
        notify-send "Battery Guard" "$message" || true
        mkdir -p "$(dirname "$state_file")"
        echo "0 1" > "$state_file"
        return
    fi

    if [ "$REPEAT_EVERY_RUNS" -le 0 ]; then
        return
    fi

    local runs_since repeats_sent
    read -r runs_since repeats_sent < "$state_file"

    if [ "$MAX_REPEATS" -gt 0 ] && [ "$repeats_sent" -ge "$MAX_REPEATS" ]; then
        return
    fi

    runs_since=$((runs_since + 1))
    if [ "$runs_since" -ge "$REPEAT_EVERY_RUNS" ]; then
        notify-send "Battery Guard" "$message" || true
        repeats_sent=$((repeats_sent + 1))
        runs_since=0
    fi

    echo "$runs_since $repeats_sent" > "$state_file"
}

# Above the stop threshold on AC: remind to unplug so it can discharge.
if [ "$AC_ONLINE" -eq 1 ] && [ "$CAP" -ge "$STOP_THRESHOLD" ]; then
    maybe_notify "$STATE_HIGH" "Battery is at ${CAP}%. Unplug the charger to let it discharge."
else
    rm -f "$STATE_HIGH"
fi

# Below the start threshold on battery: remind to plug in so charging resumes.
if [ "$AC_ONLINE" -eq 0 ] && [ "$CAP" -le "$START_THRESHOLD" ]; then
    maybe_notify "$STATE_LOW" "Battery is at ${CAP}%. Plug in the charger to start charging."
else
    rm -f "$STATE_LOW"
fi
