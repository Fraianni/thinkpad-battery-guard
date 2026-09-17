#!/bin/bash
set -e

systemctl disable --now battery-guard.timer || true

rm -f /usr/local/sbin/battery-guard.sh
rm -f /etc/systemd/system/battery-guard.service
rm -f /etc/systemd/system/battery-guard.timer
rm -f /var/lib/battery-guard-state

systemctl daemon-reload

echo "Battery Guard removed."
