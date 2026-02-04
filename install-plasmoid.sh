#!/bin/bash

# PlasmaNGenuity - Quick Install Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_DIR="$SCRIPT_DIR/plasmoid"

echo "========================================"
echo "  PlasmaNGenuity - Quick Install"
echo "========================================"
echo

# Check for KDE Plasma 6
if ! command -v plasmashell &> /dev/null; then
    echo "Error: KDE Plasma is not installed."
    exit 1
fi

if ! command -v kpackagetool6 &> /dev/null; then
    echo "Error: kpackagetool6 not found. This widget requires Plasma 6."
    exit 1
fi

# Check for hidapi
if ! python3 -c "import hid" 2>/dev/null; then
    echo "Warning: hidapi Python module not found."
    echo "Install it with: pip install hidapi"
    echo "Or: sudo pacman -S python-hidapi (Arch/Manjaro)"
    echo
fi

echo "[1/3] Removing old version (if exists)..."
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.plasmangenuity 2>/dev/null || true

echo "[2/3] Installing plasmoid..."
kpackagetool6 -t Plasma/Applet -i "$PLASMOID_DIR"

echo "[3/3] Done!"
echo
echo "========================================="
echo "  Installation complete!"
echo "========================================="
echo
echo "The widget should now appear in your system tray."
echo
echo "If not visible, add it manually:"
echo "  1. Right-click on the system tray"
echo "  2. Select 'Configure System Tray...'"
echo "  3. Go to 'Entries' tab"
echo "  4. Find 'PlasmaNGenuity' and set to 'Always shown'"
echo
echo "Make sure udev rules are installed for non-root access:"
echo "  sudo cp 99-hyperx-pulsefire.rules /etc/udev/rules.d/"
echo "  sudo udevadm control --reload-rules"
echo
echo "To uninstall:"
echo "  kpackagetool6 -t Plasma/Applet -r org.kde.plasma.plasmangenuity"
