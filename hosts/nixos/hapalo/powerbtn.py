#!/usr/bin/env python3
"""Power button daemon (hapalo): short press -> sw (hibernate + boot Windows),
hold >= 2s -> poweroff. logind HandlePowerKey=ignore; this daemon owns the key.

Matches only the ACPI power-button devices (PNP0C0C / LNXPWRBN) so keyboard
KEY_POWER keys and their traffic are never touched. Rescans for devices every
few seconds (event numbers can change across boots). Fallback if this dies:
hardware 4-5s hold still hard-poweroffs via firmware.
"""
import subprocess
import time

import evdev

HOLD_SECS = 2.0
POLL_SECS = 5.0


def is_acpi_power_button(dev):
    try:
        caps = dev.capabilities()
    except Exception:
        return False
    keys = caps.get(evdev.ecodes.EV_KEY, [])
    if evdev.ecodes.KEY_POWER not in keys:
        return False
    phys = dev.phys or ""
    return phys.startswith(("PNP0C0C", "LNXPWRBN"))


def act(held):
    if held >= HOLD_SECS:
        print(f"powerbtn: held {held:.2f}s -> poweroff", flush=True)
        subprocess.run(["/run/current-system/sw/bin/systemctl", "poweroff"], check=False)
    else:
        print(f"powerbtn: tap {held:.2f}s -> sw", flush=True)
        subprocess.run(["/run/current-system/sw/bin/sw"], check=False)


watched = {}  # path -> InputDevice


def watch(dev):
    press_t = None
    try:
        for event in dev.read_loop():
            if event.type == evdev.ecodes.EV_KEY and event.code == evdev.ecodes.KEY_POWER:
                if event.value == 1:
                    press_t = time.monotonic()
                elif event.value == 0 and press_t is not None:
                    act(time.monotonic() - press_t)
                    press_t = None
    except OSError:
        pass  # device went away — drop it; the scan loop re-opens it


while True:
    for path in evdev.list_devices():
        if path in watched:
            continue
        try:
            dev = evdev.InputDevice(path)
        except OSError:
            continue
        if is_acpi_power_button(dev):
            print(f"powerbtn: watching {path} ({dev.name})", flush=True)
            watched[path] = dev
            import threading

            threading.Thread(target=watch, args=(dev,), daemon=True).start()
    # drop vanished devices so they can be re-opened
    for path, dev in list(watched.items()):
        if not dev.fn or not dev.exists():
            watched.pop(path, None)
    time.sleep(POLL_SECS)
