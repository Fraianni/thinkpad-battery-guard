#!/bin/bash

systemctl --user disable --now battery-reminder.timer 2>/dev/null || true

rm -f "$HOME/.local/bin/battery-reminder.sh"
rm -f "$HOME/.config/systemd/user/battery-reminder.service"
rm -f "$HOME/.config/systemd/user/battery-reminder.timer"
rm -f "$HOME/.cache/battery-reminder-state-high"
rm -f "$HOME/.cache/battery-reminder-state-low"

systemctl --user daemon-reload

echo "Battery Reminder removed."
