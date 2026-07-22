import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components
import "battery" as BatteryComponents

Item {
    id: root

    property int islandState: 0
    property var theme: null
    property real islandBatteryW: 0
    property real islandBatteryH: 0

    readonly property bool panelOpen: islandState === 9
    readonly property real percentage: Math.max(0, Math.min(100, Number(BatteryService.percentage) || 0))
    readonly property real wattage: Math.abs(Number(BatteryService.smoothWattage) || 0)

    // Visual tokens: restrained, dark, and slightly luminous.
    readonly property string mainFont: theme ? theme.fontMain : "Inter"
    readonly property string iconFont: theme ? theme.fontIcon : "Material Symbols Rounded"
    readonly property color textMain: theme ? theme.textMain : "#E8EAF2"
    readonly property color textSub: theme ? theme.textSub : "#9298AB"
    readonly property color hairline: Qt.rgba(1, 1, 1, 0.08)
    readonly property color surfaceLow: Qt.rgba(1, 1, 1, 0.025)
    readonly property color surfaceHigh: Qt.rgba(1, 1, 1, 0.075)

    readonly property color chargingColor: "#63E6C7"
    readonly property color oneshotColor: theme ? theme.colorSystemShimmer : "#7C9CFF"
    readonly property color acColor: "#89B4FA"
    readonly property color activeChargingColor: BatteryService.isOneshotCharging
                                                   ? oneshotColor
                                                   : chargingColor

    readonly property int motionFast: 150
    readonly property int motionMedium: 280
    readonly property int motionSlow: 420

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function mixColor(a, b, amount) {
        var t = clamp(amount, 0, 1);
        return Qt.rgba(
            a.r + (b.r - a.r) * t,
            a.g + (b.g - a.g) * t,
            a.b + (b.b - a.b) * t,
            1.0
        );
    }

    readonly property color barColor: {
        if (BatteryService.isCharging)
            return activeChargingColor;
        if (BatteryService.isOnAC)
            return acColor;

        var pct = percentage;
        if (pct > 60)
            return mixColor(Qt.color("#D8C982"), Qt.color("#79D6A1"), (pct - 60) / 40.0);
        if (pct > 30)
            return mixColor(Qt.color("#D99672"), Qt.color("#D8C982"), (pct - 30) / 30.0);
        if (pct > 10)
            return mixColor(Qt.color("#D4777E"), Qt.color("#D99672"), (pct - 10) / 20.0);
        return Qt.color("#D96673");
    }

    readonly property color wattageColor: {
        var w = wattage;
        if (w < 8)
            return "#79D6A1";
        if (w < 20)
            return mixColor(Qt.color("#79D6A1"), Qt.color("#D8C982"), (w - 8) / 12.0);
        if (w < 35)
            return mixColor(Qt.color("#D8C982"), Qt.color("#D99672"), (w - 20) / 15.0);
        if (w < 45)
            return mixColor(Qt.color("#D99672"), Qt.color("#D4777E"), (w - 35) / 10.0);
        return "#D96673";
    }

    readonly property color statusColor: {
        if (BatteryService.isOneshotCharging)
            return oneshotColor;
        if (BatteryService.isCharging)
            return chargingColor;
        if (BatteryService.isOnAC)
            return acColor;
        return textSub;
    }

    readonly property string statusText: {
        if (BatteryService.isOneshotCharging)
            return "One-Shot Override";
        if (BatteryService.isCharging)
            return "Charging";
        if (BatteryService.isOnAC)
            return BatteryService.status === "Full" ? "Fully Charged" : "Plugged In";
        return "On Battery";
    }

    readonly property string statusIcon: {
        if (BatteryService.isCharging)
            return "bolt";
        if (BatteryService.isOnAC)
            return "power";
        return "battery_horiz_050";
    }

    readonly property string batteryIcon: {
        if (BatteryService.isCharging)
            return "battery_charging_full";
        if (percentage > 80)
            return "battery_full";
        if (percentage > 60)
            return "battery_5_bar";
        if (percentage > 40)
            return "battery_4_bar";
        if (percentage > 20)
            return "battery_3_bar";
        if (percentage > 10)
            return "battery_1_bar";
        return "battery_alert";
    }

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

    Column {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        BatteryComponents.HeaderRow {
            id: headerRow
            rootItem: root
            width: parent.width
        }

        BatteryComponents.BatteryBar {
            id: batteryBarContainer
            rootItem: root
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.hairline
            opacity: root.panelOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.motionMedium } }
        }

        BatteryComponents.HealthRow {
            id: healthRow
            rootItem: root
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.hairline
            opacity: root.panelOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.motionMedium } }
        }

        BatteryComponents.ChargeLimitRow {
            id: chargeLimitRow
            rootItem: root
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.hairline
            opacity: root.panelOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.motionMedium } }
        }

        BatteryComponents.ProfileRow {
            id: profileRow
            rootItem: root
            width: parent.width
        }

        BatteryComponents.PeripheralsColumn {
            id: peripheralsColumn
            rootItem: root
            width: parent.width
        }
    }
}
