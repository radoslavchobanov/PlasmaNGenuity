# HyperX Pulsefire Dart Configuration Tool

**Full NGenuity replacement for the HyperX Pulsefire Dart wireless gaming mouse on Linux.**

HyperX only provides NGenuity (Windows-only) for configuring their mice. This project provides a complete Linux alternative with both a **native KDE Plasma 6 widget** and a standalone Qt application.

[![PyPI](https://img.shields.io/pypi/v/hyperx-pulsefire-battery)](https://pypi.org/project/hyperx-pulsefire-battery/)
[![Python 3.8+](https://img.shields.io/badge/python-3.8%2B-green)](https://www.python.org/)
[![KDE Plasma 6](https://img.shields.io/badge/KDE_Plasma-6-blue)](https://kde.org/plasma-desktop/)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

---

## PlasmaNGenuity - KDE Plasma 6 Widget

A native system tray widget for KDE Plasma 6 that monitors your HyperX Pulsefire Dart battery.

### Quick Install (Plasma Widget)

```bash
git clone https://github.com/radoslavchobanov/hyperx-pulsefire-battery.git
cd hyperx-pulsefire-battery
./install-plasmoid.sh
```

### Features

- Native Plasma 6 system tray integration
- Real-time battery percentage display
- Charging status indicator
- Connection mode display (wireless/wired)
- Color-coded battery level (green → yellow → orange → red)
- One-click access to configuration panel

### Requirements

- KDE Plasma 6
- Python 3.8+ with `hidapi` module
- udev rules for non-root access

---

## Standalone Application

### System Tray Application
- **Modern mouse icon** with battery level fill bar
- **Color-coded status**: green (>50%) → yellow (25-50%) → orange (10-25%) → red (<10%)
- **Charging animation**: pulsing lightning bolt indicator
- **Instant hotplug detection** via udev monitoring
- **Left-click** opens the configuration panel
- **Right-click** context menu for quick actions

### Configuration Panel
A Plasma-style popup panel with full mouse configuration:

| Tab | Features |
|-----|----------|
| **Info** | Firmware version, battery %, charging status, connection mode, voltage |
| **DPI** | 5 profiles with enable/disable, DPI values (50-16000), per-profile colors |
| **LED** | Logo/scroll wheel lighting, effects (static/breathing/spectrum/trigger), color picker, brightness, speed |
| **Buttons** | Remap 6 buttons to mouse/keyboard/media/DPI functions |
| **Macros** | Record and assign macro sequences with delays |
| **Settings** | Polling rate (125/250/500/1000 Hz), battery alert threshold |

### CLI Tool
- Quick battery check from terminal
- JSON output for scripting
- Continuous monitoring mode
- Device listing

---

## Supported Devices

| Device | USB ID | Mode |
|--------|--------|------|
| HyperX Pulsefire Dart (wireless dongle) | `0951:16E1` | Wireless |
| HyperX Pulsefire Dart (USB cable) | `0951:16E2` | Wired |

---

## Installation

### Option 1: Plasma Widget Only

```bash
git clone https://github.com/radoslavchobanov/hyperx-pulsefire-battery.git
cd hyperx-pulsefire-battery
./install-plasmoid.sh
```

### Option 2: Full Installation (pip)

#### 1. Install system dependencies

**Arch / Manjaro:**
```bash
sudo pacman -S hidapi python-pyqt5 python-pyudev python-hidapi
```

**Debian / Ubuntu:**
```bash
sudo apt install libhidapi-hidraw0 python3-pyqt5 python3-pyudev python3-hid
```

**Fedora:**
```bash
sudo dnf install hidapi python3-qt5 python3-pyudev python3-hidapi
```

#### 2. Install from PyPI

```bash
# Full installation with GUI
pip install "hyperx-pulsefire-battery[tray]"

# CLI only
pip install hyperx-pulsefire-battery
```

#### 3. Set up udev rules (required for non-root access)

```bash
sudo cp 99-hyperx-pulsefire.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Then **unplug and replug** your wireless dongle.

### Option 3: Arch Linux / Manjaro (PKGBUILD)

```bash
git clone https://github.com/radoslavchobanov/hyperx-pulsefire-battery.git
cd hyperx-pulsefire-battery
makepkg -si
```

---

## Usage

### Plasma Widget

After installation, the widget appears in your system tray. If not visible:

1. Right-click on the system tray
2. Select "Configure System Tray..."
3. Go to "Entries" tab
4. Find "PlasmaNGenuity" and set to "Always shown"

### Standalone Tray Application

```bash
hyperx-battery-tray &
```

### CLI

```bash
# Show battery status
hyperx-battery

# JSON output (for scripts/waybar)
hyperx-battery --json

# Continuous monitoring
hyperx-battery --watch --interval 10

# List detected devices
hyperx-battery --list
```

---

## Troubleshooting

### "Device not found"
- Ensure the wireless dongle is plugged in
- Check udev rules: `ls /etc/udev/rules.d/99-hyperx-pulsefire.rules`
- Run `hyperx-battery --list` to see detected interfaces
- Try running with `sudo` to rule out permission issues

### "IO Error: open failed"
- udev rules not installed or not active
- Run: `sudo udevadm control --reload-rules && sudo udevadm trigger`
- Unplug and replug the dongle

### Widget shows "Not Connected"
- Mouse/dongle is not connected or not detected
- Check USB connection
- Wait a few seconds after plugging in
- Verify hidapi is installed: `python3 -c "import hid"`

---

## Uninstall

### Plasma Widget
```bash
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.plasmangenuity
```

### pip package
```bash
pip uninstall hyperx-pulsefire-battery
```

---

## Credits

- Protocol reverse engineering by [santeri3700](https://github.com/santeri3700/hyperx_pulsefire_dart_reverse_engineering)
- Inspired by the lack of Linux support from HyperX/HP

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Note:** This is an unofficial project and is not affiliated with HyperX or HP Inc.
