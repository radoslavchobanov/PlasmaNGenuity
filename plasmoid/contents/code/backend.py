#!/usr/bin/env python3
"""
PlasmaNGenuity - Plasma Widget Backend
Outputs comprehensive device status as JSON for the KDE Plasma applet

Uses the same protocol as the main hyperx_battery module.
"""

import json
import sys

try:
    import hid
except ImportError:
    print(json.dumps({
        "error": "hidapi not installed",
        "connected": False
    }))
    sys.exit(0)

# HyperX Pulsefire Dart USB IDs
VENDOR_ID = 0x0951
PRODUCT_ID_WIRELESS = 0x16E1
PRODUCT_ID_WIRED = 0x16E2
USAGE_PAGE_WIRELESS = 0xFF00
USAGE_PAGE_WIRED = 0xFF13

# HID packet size
PACKET_SIZE = 64

# Command bytes (from protocol.py)
CMD_HW_INFO = 0x50
CMD_HEARTBEAT = 0x51
CMD_LED_QUERY = 0x52
CMD_DPI_QUERY = 0x53


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


def _make_packet(data):
    """Create a 64-byte HID packet with report ID prefix."""
    packet = [0x00] * PACKET_SIZE
    packet[0] = 0x00  # Report ID
    for i, byte in enumerate(data):
        if i + 1 < PACKET_SIZE:
            packet[i + 1] = byte
    return packet


def send_command(dev, cmd):
    """Send a command and read response."""
    packet = _make_packet([cmd])
    dev.write(packet)
    response = dev.read(PACKET_SIZE, timeout_ms=1000)
    return response


def get_battery_status(dev):
    """Query battery status from the mouse."""
    response = send_command(dev, CMD_HEARTBEAT)
    if not response or len(response) < 6 or response[0] != CMD_HEARTBEAT:
        return None, None
    return response[4], response[5] == 0x01


def get_hw_info(dev):
    """Query hardware information."""
    response = send_command(dev, CMD_HW_INFO)
    if not response or len(response) < 32 or response[0] != CMD_HW_INFO:
        return None

    # Product ID at bytes 4-5 (little-endian)
    product_id = response[4] | (response[5] << 8)

    # Vendor ID at bytes 6-7 (little-endian)
    vendor_id = response[6] | (response[7] << 8)

    # Device name is null-terminated string starting at byte 12
    name_bytes = response[12:44]
    null_idx = name_bytes.index(0) if 0 in name_bytes else len(name_bytes)
    device_name = bytes(name_bytes[:null_idx]).decode('ascii', errors='ignore')

    # Firmware version from byte 3
    firmware_version = f"{response[3]}.0.0"

    return {
        "firmware": firmware_version,
        "device_name": device_name or "HyperX Pulsefire Dart",
        "vendor_id": f"0x{vendor_id:04X}",
        "product_id": f"0x{product_id:04X}"
    }


def get_dpi_settings(dev):
    """Query DPI settings."""
    response = send_command(dev, CMD_DPI_QUERY)
    if not response or len(response) < 30 or response[0] != CMD_DPI_QUERY:
        return None

    # Active profile at byte 5
    active_profile = response[5]

    # DPI values are 2-byte little-endian at bytes 10, 12, 14, 16, 18
    # Each value is DPI / 50
    dpi_offsets = [10, 12, 14, 16, 18]
    dpi_values = []
    for offset in dpi_offsets:
        raw = response[offset] | (response[offset + 1] << 8)
        dpi_values.append(raw * 50)

    # Colors are at bytes 22+ (3 bytes RGB per profile)
    colors = []
    for i in range(5):
        offset = 22 + i * 3
        if offset + 2 < len(response):
            r, g, b = response[offset], response[offset + 1], response[offset + 2]
            colors.append(f"#{r:02X}{g:02X}{b:02X}")
        else:
            colors.append("#FFFFFF")

    # Build profiles list
    profiles = []
    for i in range(5):
        profiles.append({
            "index": i + 1,
            "dpi": dpi_values[i] if i < len(dpi_values) else 800,
            "enabled": True,  # Query doesn't return enable mask directly
            "active": i == active_profile,
            "color": colors[i] if i < len(colors) else "#FFFFFF"
        })

    return {
        "active_profile": active_profile + 1,
        "profiles": profiles
    }


def get_led_settings(dev):
    """Query LED settings."""
    response = send_command(dev, CMD_LED_QUERY)
    if not response or len(response) < 21 or response[0] != CMD_LED_QUERY:
        return None

    # LED data at bytes 17-20: brightness, R, G, B
    brightness = response[17]
    r = response[18]
    g = response[19]
    b = response[20]

    return {
        "effect": "Static",  # Query doesn't return effect type clearly
        "target": "Both",
        "color": f"#{r:02X}{g:02X}{b:02X}",
        "brightness": brightness,
        "speed": 0
    }


def main():
    device_info, mode = find_device()

    if not device_info:
        print(json.dumps({
            "error": "Device not found",
            "connected": False
        }))
        return

    try:
        dev = hid.device()
        dev.open_path(device_info["path"])
        dev.set_nonblocking(False)

        result = {
            "connected": True,
            "mode": mode,
            "error": None
        }

        # Get battery
        battery, charging = get_battery_status(dev)
        if battery is not None:
            result["battery"] = battery
            result["charging"] = charging
        else:
            result["battery"] = None
            result["charging"] = False

        # Get hardware info
        hw_info = get_hw_info(dev)
        if hw_info:
            result["hw_info"] = hw_info

        # Get DPI settings
        dpi_settings = get_dpi_settings(dev)
        if dpi_settings:
            result["dpi"] = dpi_settings

        # Get LED settings
        led_settings = get_led_settings(dev)
        if led_settings:
            result["led"] = led_settings

        dev.close()
        print(json.dumps(result))

    except Exception as e:
        print(json.dumps({
            "error": str(e),
            "connected": False
        }))


if __name__ == "__main__":
    main()
