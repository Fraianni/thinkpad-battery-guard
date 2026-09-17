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

Since `inhibit-charge` only stops further charging and does not discharge the battery for you, an optional two-way reminder is included, mirroring the thresholds in `battery-guard.sh`:

- Charger connected and battery **at or above `STOP_THRESHOLD`**: notifies to unplug the charger.
- Charger disconnected and battery **at or below `START_THRESHOLD`**: notifies to plug the charger back in.

The reminder runs as a systemd **user** service, not root, and checks state every 2 minutes. By default each notification fires once per session (i.e. once while the condition holds) and resets automatically once the condition clears — either by crossing back over the threshold or by plugging/unplugging the charger. How naggy it is can be tuned (see Configuration below): from a single light notification to repeated nagging until you act.

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

Configuration (edit these values in `battery-reminder.sh`, then reinstall):

```bash
# Keep in sync with battery-guard.sh unless you want the reminder to fire
# at different points.
START_THRESHOLD=55
STOP_THRESHOLD=80

# How naggy the reminder is while a condition keeps holding true.
REPEAT_EVERY_RUNS=0   # 0 = notify once; N = re-notify every N timer runs
MAX_REPEATS=0          # 0 = unlimited repeats; N = stop after N repeats
```

Examples, with the timer's default 2-minute interval:

- **Light (default)**: `REPEAT_EVERY_RUNS=0` — one notification per session, no repeats.
- **Intense**: `REPEAT_EVERY_RUNS=1` with `MAX_REPEATS=0` — renotifies every ~2 minutes, indefinitely, until you unplug/plug in or cross back over the threshold.
- **Occasional nudge**: `REPEAT_EVERY_RUNS=5` with `MAX_REPEATS=3` — renotifies every ~10 minutes, up to 3 extra times, then stays quiet until the condition clears.

To change how often the check itself runs (independent of repeats), edit `OnUnitActiveSec` in `battery-reminder.timer` and reinstall.

## Tested on

- Fedora Workstation
- Lenovo ThinkPad
- Linux battery interface exposing `inhibit-charge`

It may also work on other Linux laptops exposing the same sysfs interface.

## Disclaimer

Use at your own risk.

Battery and firmware behaviour varies between laptop models.
