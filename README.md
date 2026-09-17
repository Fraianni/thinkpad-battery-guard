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

## Tested on

- Fedora Workstation
- Lenovo ThinkPad
- Linux battery interface exposing `inhibit-charge`

It may also work on other Linux laptops exposing the same sysfs interface.

## Disclaimer

Use at your own risk.

Battery and firmware behaviour varies between laptop models.
