#!/bin/bash
set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run install-reminder.sh with sudo. Run it as your normal user."
    exit 1
fi

install -Dm755 battery-reminder.sh "$HOME/.local/bin/battery-reminder.sh"
install -Dm644 battery-reminder.service "$HOME/.config/systemd/user/battery-reminder.service"
install -Dm644 battery-reminder.timer "$HOME/.config/systemd/user/battery-reminder.timer"

systemctl --user daemon-reload
systemctl --user enable --now battery-reminder.timer

echo "Battery Reminder installed (user service, no sudo required)."
