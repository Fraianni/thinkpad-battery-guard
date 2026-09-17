#!/bin/bash
set -euo pipefail

# Should match the thresholds configured in battery-guard.sh
START_THRESHOLD=55
STOP_THRESHOLD=80

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

# Above the stop threshold on AC: remind to unplug so it can discharge.
if [ "$AC_ONLINE" -eq 1 ] && [ "$CAP" -ge "$STOP_THRESHOLD" ]; then
    if [ ! -f "$STATE_HIGH" ]; then
        notify-send "Battery Guard" "Battery is at ${CAP}%. Unplug the charger to let it discharge." || true
        mkdir -p "$(dirname "$STATE_HIGH")"
        touch "$STATE_HIGH"
    fi
else
    rm -f "$STATE_HIGH"
fi

# Below the start threshold on battery: remind to plug in so charging resumes.
if [ "$AC_ONLINE" -eq 0 ] && [ "$CAP" -le "$START_THRESHOLD" ]; then
    if [ ! -f "$STATE_LOW" ]; then
        notify-send "Battery Guard" "Battery is at ${CAP}%. Plug in the charger to start charging." || true
        mkdir -p "$(dirname "$STATE_LOW")"
        touch "$STATE_LOW"
    fi
else
    rm -f "$STATE_LOW"
fi
