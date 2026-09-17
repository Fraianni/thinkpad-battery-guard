#!/bin/bash
set -euo pipefail

THRESHOLD=80

BAT_CAPACITY="/sys/class/power_supply/BAT0/capacity"
STATE="$HOME/.cache/battery-reminder-state"

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

if [ "$AC_ONLINE" -eq 1 ] && [ "$CAP" -ge "$THRESHOLD" ]; then
    if [ ! -f "$STATE" ]; then
        notify-send "Battery Guard" "Battery is at ${CAP}%. Unplug the charger to let it discharge." || true
        mkdir -p "$(dirname "$STATE")"
        touch "$STATE"
    fi
else
    rm -f "$STATE"
fi
