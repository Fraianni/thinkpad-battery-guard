# ThinkPad Battery Guard

A tiny systemd-based battery charge guard for Linux laptops that expose:

```text
/sys/class/power_supply/BAT0/charge_behaviour
```

with support for:

```text
inhibit-charge
```

It is designed for systems where charge thresholds are exposed in sysfs but the firmware/embedded controller may still continue charging past the configured stop threshold.

## How it works

Battery Guard checks the battery percentage once per minute.

Default thresholds:

- Start charging at 55%
- Stop charging at 80%

When the battery reaches 80% or more:

```text
charge_behaviour = inhibit-charge
```

When the battery reaches 55% or less:

```text
charge_behaviour = auto
```

Between the two thresholds, it preserves the previous charging state.

**Important:** `inhibit-charge` prevents further charging but does not force discharge while AC is connected. The laptop keeps running on AC power and the battery stays at roughly its current percentage. To actually bring the percentage down, you need to unplug the charger and let the battery discharge naturally.

## Requirements

Linux with systemd and a battery exposing:

```bash
cat /sys/class/power_supply/BAT0/charge_behaviour
```

The output must include:

```text
inhibit-charge
```

For example:

```text
[auto] inhibit-charge force-discharge
```

## Install

```bash
git clone https://github.com/francescoianni/thinkpad-battery-guard.git
cd thinkpad-battery-guard
sudo ./install.sh
```

Check the timer status:

```bash
systemctl status battery-guard.timer
```

Check the current battery charging behaviour:

```bash
cat /sys/class/power_supply/BAT0/charge_behaviour
```

## Configuration

Edit these values in `battery-guard.sh`:

```bash
START_THRESHOLD=55
STOP_THRESHOLD=80
```

Then reinstall:

```bash
sudo ./install.sh
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Optional desktop reminder

Since `inhibit-charge` only stops further charging and does not discharge the battery for you, an optional reminder is included. It notifies you (via `notify-send`) when the charger is connected and the battery is at or above the configured threshold, prompting you to unplug it if you want the percentage to go down.

The reminder runs as a systemd **user** service, not root, and checks state every 2 minutes. It notifies once per "charger connected" session and resets automatically when you unplug.

Install:

```bash
./install-reminder.sh
```

Uninstall:

```bash
./uninstall-reminder.sh
```

**Do not use `sudo` with these scripts.** They install into `~/.local/bin` and `~/.config/systemd/user/` and are managed with `systemctl --user`.

Check the reminder timer status:

```bash
systemctl --user status battery-reminder.timer
```

Configuration (edit `THRESHOLD` in `battery-reminder.sh`, then reinstall):

```bash
THRESHOLD=80
```

## Tested on

- Fedora Workstation
- Lenovo ThinkPad
- Linux battery interface exposing `inhibit-charge`

It may also work on other Linux laptops exposing the same sysfs interface.

## Disclaimer

Use at your own risk.

Battery and firmware behaviour varies between laptop models.
