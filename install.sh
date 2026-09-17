#!/bin/bash
set -e

install -Dm755 battery-guard.sh /usr/local/sbin/battery-guard.sh
install -Dm644 battery-guard.service /etc/systemd/system/battery-guard.service
install -Dm644 battery-guard.timer /etc/systemd/system/battery-guard.timer

systemctl daemon-reload
systemctl enable --now battery-guard.timer
systemctl start battery-guard.service

echo "Battery Guard installed."
