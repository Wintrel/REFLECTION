import "../../../../core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components
import "battery" as BatteryComponents

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var theme: null
    property real islandBatteryW: 0
    property real islandBatteryH: 0

    readonly property bool panelOpen: islandState === State.IslandState.battery
    readonly property real percentage: Math.max(0, Math.min(100, Number(BatteryService.percentage) || 0))
    readonly property real wattage: Math.abs(Number(BatteryService.smoothWattage) || 0)

    // Visual tokens
    readonly property string mainFont: theme ? theme.fontMain : "Inter"
    readonly property string iconFont: theme ? theme.fontIcon : "Material Symbols Rounded"
    readonly property color textMain: theme ? theme.textMain : "#E8EAF2"
    readonly property color textSub: theme ? theme.textSub : "#9298AB"
    readonly property color hairline: Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceLow: Qt.rgba(1, 1, 1, 0.025)
    readonly property color surfaceHigh: Qt.rgba(1, 1, 1, 0.075)

    readonly property color chargingColor: "#79D6A1"
    readonly property color oneshotColor: theme ? theme.colorSystemShimmer : "#7C9CFF"
    readonly property color acColor: "#89B4FA"
    readonly property color activeChargingColor: BatteryService.isOneshotCharging
                                                   ? oneshotColor
                                                   : chargingColor

    readonly property int motionFast: 150
    readonly property int motionMedium: 280
    readonly property int motionSlow: 420

    width: Math.max(0, islandBatteryW - 32)
    height: Math.max(0, islandBatteryH - 32)
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: Math.max(0, (islandBatteryH - height) / 2)

    opacity: panelOpen ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.motionFast
            easing.type: Easing.OutSine
        }
    }

    Binding {
        target: BatteryService
        property: "panelOpen"
        value: root.panelOpen
    }

    Components.Starfield {
        anchors.fill: parent
        starCount: 24
        starColor: root.textMain
        opacity: 0.28
    }

    // A soft veil keeps the stars atmospheric rather than decorative.
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.08) }
            GradientStop { position: 0.55; color: Qt.rgba(0, 0, 0, 0.22) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.42) }
        }
    }

    // ── Content Column (TopBar + Dashboard Grid) ──────────────────
    Column {
        anchors.centerIn: parent
        spacing: 12

        // Top Navigation & Quick Switcher Bar
        BatteryComponents.BatteryTopBar {
            width: dashboardRow.width
            theme: root.theme
            islandState: root.islandState
        }

        // ── Main Dashboard Layout (Grid + Vertical Battery Card) ──
        Row {
            id: dashboardRow
            spacing: 16

            // Left Section: 2 Rows of System Monitor Cards
            Column {
                width: 856
                spacing: 16

                // Row 1: CPU & GPU (Equal Widths)
                Row {
                    width: parent.width
                    height: 140
                    spacing: 16

                    BatteryComponents.SystemMonitorCard {
                        width: (parent.width - 16) / 2
                        height: parent.height
                        theme: root.theme
                        title: "CPU"
                        subtitle: "AMD Ryzen 5 5600H with Radeon Graphics"
                        icon: "memory"
                        usageText: "8%"
                        tempText: "67°C"
                        usageFraction: 0.08
                        accentColor: "#79D6A1"
                    }

                    BatteryComponents.SystemMonitorCard {
                        width: (parent.width - 16) / 2
                        height: parent.height
                        theme: root.theme
                        title: "GPU"
                        subtitle: "NVIDIA GeForce RTX 3050 Laptop GPU"
                        icon: "developer_board"
                        usageText: "4%"
                        tempText: "55°C"
                        usageFraction: 0.04
                        accentColor: "#79D6A1"
                    }
                }

                // Row 2: Storage, Network, and Memory
                Row {
                    width: parent.width
                    height: 140
                    spacing: 16

                    BatteryComponents.StorageCard {
                        width: 250
                        height: parent.height
                        theme: root.theme
                        title: "Storage"
                        subtitle: "26.2 / 103.5 GiB"
                        usedFraction: 0.25
                        driveName: "nvme0n1"
                        accentColor: "#79D6A1"
                    }

                    BatteryComponents.NetworkCard {
                        width: parent.width - 250 - 186 - 32 // 388px
                        height: parent.height
                        theme: root.theme
                        downloadSpeed: "7.2 KB/s"
                        uploadSpeed: "5.6 KB/s"
                        totalDown: "332.6MB"
                        totalUp: "6.6MB"
                        accentColor: "#79D6A1"
                    }

                    BatteryComponents.MemoryCard {
                        width: 186
                        height: parent.height
                        theme: root.theme
                        title: "Memory"
                        subtitle: "3.6 / 22.8 GiB"
                        usedFraction: 0.16
                        accentColor: "#79D6A1"
                    }
                }
            }

            // Right Section: Full-height Vertical Battery Card
            BatteryComponents.VerticalBatteryWidget {
                width: 174
                height: 296 // 140 + 16 + 140
                theme: root.theme
            }
        }
    }
}
