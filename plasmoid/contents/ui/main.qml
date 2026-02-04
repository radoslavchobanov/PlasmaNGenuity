/*
 * PlasmaNGenuity - KDE Plasma 6 System Tray Widget
 * Monitor HyperX Pulsefire Dart mouse battery and settings
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int batteryLevel: -1
    property bool isCharging: false
    property string connectionMode: ""
    property bool connected: false
    property bool loading: true
    property string lastError: ""

    Plasmoid.icon: "input-mouse"
    toolTipMainText: "PlasmaNGenuity"
    toolTipSubText: getTooltipText()

    preferredRepresentation: compactRepresentation

    readonly property string backendPath: Qt.resolvedUrl("../code/backend.py").toString().replace("file://", "")

    function getTooltipText() {
        if (!connected) return "Mouse not connected"
        if (batteryLevel < 0) return "Unknown"
        var text = batteryLevel + "%"
        if (isCharging) text += " (Charging)"
        if (connectionMode) text += " • " + connectionMode
        return text
    }

    function getBatteryColor() {
        if (!connected || batteryLevel < 0) return Kirigami.Theme.disabledTextColor
        if (isCharging) return Kirigami.Theme.positiveTextColor
        if (batteryLevel <= 10) return Kirigami.Theme.negativeTextColor
        if (batteryLevel <= 25) return "#FFA500"  // Orange
        if (batteryLevel <= 50) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.positiveTextColor
    }

    function getBatteryIcon() {
        if (!connected) return "input-mouse"
        if (isCharging) return "battery-charging"
        if (batteryLevel <= 10) return "battery-010"
        if (batteryLevel <= 20) return "battery-020"
        if (batteryLevel <= 30) return "battery-030"
        if (batteryLevel <= 40) return "battery-040"
        if (batteryLevel <= 50) return "battery-050"
        if (batteryLevel <= 60) return "battery-060"
        if (batteryLevel <= 70) return "battery-070"
        if (batteryLevel <= 80) return "battery-080"
        if (batteryLevel <= 90) return "battery-090"
        return "battery-100"
    }

    function refresh() {
        root.loading = true
        executable.connectSource("python3 " + backendPath)
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: (source, data) => {
            var stdout = data["stdout"]
            disconnectSource(source)
            root.loading = false

            if (!stdout || stdout.trim() === "") {
                root.connected = false
                root.lastError = "No output from backend"
                return
            }

            try {
                var result = JSON.parse(stdout)

                if (result.error && !result.connected) {
                    root.connected = false
                    root.lastError = result.error
                    root.batteryLevel = -1
                    return
                }

                root.connected = result.connected || false
                root.batteryLevel = result.battery !== null ? result.battery : -1
                root.isCharging = result.charging || false
                root.connectionMode = result.mode || ""
                root.lastError = ""

            } catch (e) {
                root.connected = false
                root.lastError = "Parse error"
            }
        }
    }

    Timer {
        interval: 60000  // Update every minute
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refresh()
    }

    compactRepresentation: MouseArea {
        id: compactRoot

        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: root.expanded = !root.expanded

        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                source: "input-mouse"
                color: getBatteryColor()
            }

            PlasmaComponents.Label {
                visible: root.connected && root.batteryLevel >= 0
                text: root.batteryLevel + "%"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: getBatteryColor()
            }
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: contentColumn.implicitHeight + Kirigami.Units.largeSpacing * 2

        header: PlasmaExtras.PlasmoidHeading {
            RowLayout {
                anchors.fill: parent

                PlasmaExtras.Heading {
                    level: 1
                    text: "HyperX Pulsefire Dart"
                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: refresh()
                    PlasmaComponents.ToolTip { text: "Refresh" }
                }
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            // Connection status
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    source: root.connected ? "network-connect" : "network-disconnect"
                    color: root.connected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    PlasmaComponents.Label {
                        text: root.connected ? "Connected" : "Not Connected"
                        font.bold: true
                    }

                    PlasmaComponents.Label {
                        visible: root.connected && root.connectionMode
                        text: root.connectionMode.charAt(0).toUpperCase() + root.connectionMode.slice(1) + " mode"
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.7
                    }

                    PlasmaComponents.Label {
                        visible: !root.connected && root.lastError
                        text: root.lastError
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.7
                    }
                }
            }

            // Battery section
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.connected

                RowLayout {
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: "Battery"
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: root.batteryLevel >= 0 ? root.batteryLevel + "%" : "—"
                        color: getBatteryColor()
                        font.bold: true
                    }

                    Kirigami.Icon {
                        visible: root.isCharging
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        source: "battery-charging"
                        color: Kirigami.Theme.positiveTextColor
                    }
                }

                // Battery progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: Kirigami.Units.gridUnit * 0.6
                    radius: height / 2
                    color: Kirigami.Theme.backgroundColor
                    border.color: Kirigami.Theme.disabledTextColor
                    border.width: 1
                    opacity: 0.5

                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 2
                        }
                        width: Math.max(0, (parent.width - 4) * (root.batteryLevel >= 0 ? root.batteryLevel / 100 : 0))
                        radius: height / 2
                        color: getBatteryColor()

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                        }
                    }
                }

                PlasmaComponents.Label {
                    visible: root.isCharging
                    text: "Charging..."
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.positiveTextColor
                }
            }

            // Not connected message
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.connected
                spacing: Kirigami.Units.smallSpacing

                Item { Layout.fillHeight: true }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Mouse not detected"
                    opacity: 0.7
                }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Make sure the wireless dongle\nis plugged in"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    opacity: 0.5
                }

                Item { Layout.fillHeight: true }
            }

            Item { Layout.fillHeight: true }

            // Open config panel button
            PlasmaComponents.Button {
                Layout.fillWidth: true
                visible: root.connected
                text: "Open Configuration Panel"
                icon.name: "configure"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/bin/hyperx-battery-tray")
                }
            }
        }
    }
}
