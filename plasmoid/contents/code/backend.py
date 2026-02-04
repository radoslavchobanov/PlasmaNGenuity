#!/usr/bin/env python3
"""
PlasmaNGenuity - Plasma Widget Backend
Outputs battery status as JSON for the KDE Plasma applet
"""

import json
import sys

try:
    import hid
except ImportError:
    print(json.dumps({"error": "hidapi not installed", "battery": None, "charging": False, "mode": None}))
    sys.exit(0)

# HyperX Pulsefire Dart USB IDs
VENDOR_ID = 0x0951
PRODUCT_ID_WIRELESS = 0x16E1
PRODUCT_ID_WIRED = 0x16E2
USAGE_PAGE_WIRELESS = 0xFF00
USAGE_PAGE_WIRED = 0xFF13

# HID packet size and command
PACKET_SIZE = 64
CMD_HEARTBEAT = 0x51


def find_device():
    """Find the HyperX Pulsefire Dart HID device."""
    try:
        devices = hid.enumerate(VENDOR_ID)
    except Exception:
        return None, None

    for dev in devices:
        if dev["product_id"] == PRODUCT_ID_WIRELESS:
            if dev["usage_page"] == USAGE_PAGE_WIRELESS or dev["interface_number"] == 2:
                return dev, "wireless"
        elif dev["product_id"] == PRODUCT_ID_WIRED:
            if dev["usage_page"] == USAGE_PAGE_WIRED or dev["interface_number"] == 1:
                return dev, "wired"

    return None, None


def get_battery_status(device_path):
    """Query battery status from the mouse."""
    try:
        dev = hid.device()
        dev.open_path(device_path)
        dev.set_nonblocking(False)

        packet = [0x00] * PACKET_SIZE
        packet[0] = 0x00  # Report ID
        packet[1] = CMD_HEARTBEAT
        dev.write(packet)

        response = dev.read(PACKET_SIZE, timeout_ms=1000)
        dev.close()

        if not response:
            return None, None, "No response"

        if response[0] == CMD_HEARTBEAT:
            return response[4], response[5] == 0x01, None

        return None, None, "Unexpected response"
    except IOError as e:
        return None, None, str(e)
    except Exception as e:
        return None, None, str(e)


def main():
    device_info, mode = find_device()

    if not device_info:
        print(json.dumps({
            "error": "Device not found",
            "battery": None,
            "charging": False,
            "mode": None,
            "connected": False
        }))
        return

    battery, charging, error = get_battery_status(device_info["path"])

    if error:
        print(json.dumps({
            "error": error,
            "battery": None,
            "charging": False,
            "mode": mode,
            "connected": False
        }))
        return

    print(json.dumps({
        "error": None,
        "battery": battery,
        "charging": charging,
        "mode": mode,
        "connected": True
    }))


if __name__ == "__main__":
    main()
