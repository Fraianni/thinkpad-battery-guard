#!/bin/bash

BAT="/sys/class/power_supply/BAT0"

START_THRESHOLD=55
STOP_THRESHOLD=80

STATE="/var/lib/battery-guard-state"

CAP=$(cat "$BAT/capacity")

if [ "$CAP" -ge "$STOP_THRESHOLD" ]; then
    echo inhibit-charge > "$BAT/charge_behaviour"
    echo hold > "$STATE"

elif [ "$CAP" -le "$START_THRESHOLD" ]; then
    echo auto > "$BAT/charge_behaviour"
    echo charge > "$STATE"

else
    if [ -f "$STATE" ] && grep -q '^charge$' "$STATE"; then
        echo auto > "$BAT/charge_behaviour"
    else
        echo inhibit-charge > "$BAT/charge_behaviour"
        echo hold > "$STATE"
    fi
fi
