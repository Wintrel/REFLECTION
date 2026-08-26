import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Item {
    id: rootItem
    
    // Pass theme from parent
    property var theme: null
    
    property int percentage: Math.max(0, Math.min(100, Number(BatteryService.percentage) || 0))
    
    // Profile information
    readonly property int currentProfileIndex: RogService.performanceProfile !== undefined ? RogService.performanceProfile : 1
    readonly property var profileIcons: ["spa", "tune", "bolt"]
    readonly property var profileNames: ["Quiet", "Balanced", "Performance"]
    readonly property var profileColors: ["#79D6A1", "#89B4FA", "#FF6B6B"]

    property bool isFlashingProfile: false
    property string flashProfileName: ""
    property color flashColor: "#79D6A1"

    function getProfileColor(idx) {
        return profileColors[idx] || "#89B4FA";
    }

    function cycleProfile() {
        var nextIdx = (currentProfileIndex + 1) % 3;
        RogService.setPerformanceProfile(nextIdx);
        if (typeof BatteryService.setAsusProfile === "function") {
            BatteryService.setAsusProfile(profileNames[nextIdx]);
        }
        flashProfileName = profileNames[nextIdx];
        flashColor = getProfileColor(nextIdx);
        isFlashingProfile = true;
        profileSweepAnim.restart();
        flashTimer.restart();
    }

    Timer {
        id: flashTimer
        interval: 1800
        repeat: false
        onTriggered: isFlashingProfile = false
    }

    readonly property color standardBarColor: {
        if (BatteryService.isOneshotCharging)
            return "#FFB800";
        if (BatteryService.isCharging)
            return "#79D6A1";
        if (BatteryService.isOnAC)
            return "#89B4FA";
        
        if (percentage > 60) return "#79D6A1";
        if (percentage > 20) return "#D8C982";
        return "#D96673";
    }

    // Momentarily switches to profile color, then fades smoothly back
    readonly property color barColor: isFlashingProfile ? flashColor : standardBarColor

    // Hold-to-Charge One-Shot physics
    property real holdProgress: 0.0
    property real burstProgress: 0.0

    SequentialAnimation {
        id: oneshotBurstAnim
        NumberAnimation { target: rootItem; property: "burstProgress"; from: 1.0; to: 0.0; duration: 450; easing.type: Easing.OutQuad }
    }

    NumberAnimation {
        id: holdAnim
        target: rootItem
        property: "holdProgress"
        to: cardMa.pressed ? 1.0 : 0.0
        duration: cardMa.pressed ? 750 : 180
        easing.type: cardMa.pressed ? Easing.InQuad : Easing.OutQuad
        running: true
    }

    implicitWidth: 174
    implicitHeight: 296

    // Outer Hold & Burst Glow
    RectangularGlow {
        anchors.fill: cardBg
        glowRadius: 16 + (rootItem.holdProgress * 12) + (rootItem.burstProgress * 20)
        spread: 0.10 + (rootItem.holdProgress * 0.15)
        color: BatteryService.isOneshotCharging ? "#FFB800" : (rootItem.holdProgress > 0 ? "#FFB800" : rootItem.barColor)
        cornerRadius: cardBg.radius + glowRadius
        opacity: Math.max(rootItem.holdProgress * 0.85, Math.max(rootItem.burstProgress * 0.95, (BatteryService.isOneshotCharging ? 0.45 : 0.0)))
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 250 } }
    }

    // Card background
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 20
        scale: 1.0 - (rootItem.holdProgress * 0.03) + (rootItem.burstProgress * 0.04)
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

        color: rootItem.theme ? rootItem.theme.surfaceOverlay : Qt.rgba(1, 1, 1, 0.05)
        border.color: BatteryService.isOneshotCharging
                      ? Qt.rgba(1.0, 0.72, 0.0, 0.7)
                      : (rootItem.holdProgress > 0
                         ? Qt.rgba(1.0, 0.72, 0.0, rootItem.holdProgress)
                         : (cardMa.containsMouse 
                            ? Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, 0.4) 
                            : (rootItem.theme ? Qt.lighter(rootItem.theme.surfaceOverlay, 1.2) : Qt.rgba(1, 1, 1, 0.08))))
        border.width: (BatteryService.isOneshotCharging || rootItem.holdProgress > 0) ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Mask shape for rounded corners
        Rectangle {
            id: cardMask
            anchors.fill: parent
            radius: cardBg.radius
            visible: false
        }

        // Fill Container with smooth OpacityMask to prevent corner bleed
        Item {
            id: fillContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: cardMask
            }

            // Vertical fill
            Item {
                id: batteryFill
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * (rootItem.percentage / 100.0)

                Behavior on height { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }

                // Fill rectangle
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, rootItem.isFlashingProfile ? 0.42 : 0.28)
                    Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                }

                // Top edge line of the fill
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: rootItem.isFlashingProfile ? 3 : 2
                    color: rootItem.barColor
                    opacity: rootItem.isFlashingProfile ? 1.0 : 0.8
                    Behavior on color { ColorAnimation { duration: 350 } }
                    Behavior on height { NumberAnimation { duration: 200 } }
                }

                // Profile pulse sweep wave
                Rectangle {
                    id: profileSweep
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 70
                    opacity: rootItem.isFlashingProfile ? 0.35 : 0.0
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: rootItem.flashColor }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    NumberAnimation on y {
                        id: profileSweepAnim
                        from: batteryFill.height + 15
                        to: -80
                        duration: 850
                        easing.type: Easing.OutCubic
                    }
                }

                // Subtle continuous charging shimmer
                Rectangle {
                    id: chargeShimmer
                    visible: BatteryService.isCharging && !rootItem.isFlashingProfile
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50
                    opacity: 0.15
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.8) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    SequentialAnimation on y {
                        loops: Animation.Infinite
                        running: chargeShimmer.visible
                        NumberAnimation {
                            from: batteryFill.height + 10
                            to: -60
                            duration: 2000
                            easing.type: Easing.InOutSine
                        }
                        PauseAnimation { duration: 500 }
                    }
                }
            }
        }

        // ── Top Header (Icon + Profile Pill Badge + Label) ────────────
        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 6

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: {
                        if (BatteryService.isCharging) return "battery_charging_full";
                        if (percentage > 80) return "battery_full";
                        if (percentage > 60) return "battery_5_bar";
                        if (percentage > 40) return "battery_4_bar";
                        if (percentage > 20) return "battery_3_bar";
                        if (percentage > 10) return "battery_1_bar";
                        return "battery_alert";
                    }
                    font.family: rootItem.theme ? rootItem.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: rootItem.barColor
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 350 } }
                }

                // Interactive ROG Profile Badge Pill
                Rectangle {
                    id: profilePill
                    height: 22
                    width: pillRow.width + 12
                    radius: 11
                    color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, cardMa.containsMouse ? 0.22 : 0.14)
                    border.color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, 0.35)
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 250 } }
                    Behavior on border.color { ColorAnimation { duration: 250 } }

                    Row {
                        id: pillRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: rootItem.profileIcons[rootItem.currentProfileIndex] || "tune"
                            font.family: rootItem.theme ? rootItem.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 11
                            color: rootItem.barColor
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 350 } }
                        }

                        Text {
                            text: rootItem.profileNames[rootItem.currentProfileIndex] || "Balanced"
                            font.family: rootItem.theme ? rootItem.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: rootItem.barColor
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 350 } }
                        }
                    }
                }
            }

            Text {
                text: "Battery"
                font.family: rootItem.theme ? rootItem.theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: rootItem.theme ? rootItem.theme.textMain : "#FFF"
            }
        }

        // ── Bottom Section (Status text + ⚡ Percentage) ──────────────
        Column {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 2

            Text {
                anchors.right: parent.right
                text: {
                    if (rootItem.isFlashingProfile) return rootItem.flashProfileName + " Active";
                    if (BatteryService.isOneshotCharging) return "One-Shot";
                    if (BatteryService.isCharging) return "Charging";
                    if (BatteryService.isOnAC) return "Plugged In";
                    return "On Battery";
                }
                font.family: rootItem.theme ? rootItem.theme.fontMain : "Inter"
                font.pixelSize: 12
                font.weight: rootItem.isFlashingProfile ? Font.Bold : Font.Normal
                color: rootItem.isFlashingProfile ? rootItem.flashColor : (rootItem.theme ? rootItem.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            Row {
                anchors.right: parent.right
                spacing: 4

                Text {
                    text: rootItem.isFlashingProfile ? (rootItem.profileIcons[rootItem.currentProfileIndex] || "bolt") : "bolt"
                    font.family: rootItem.theme ? rootItem.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 26
                    font.weight: Font.Bold
                    color: rootItem.barColor
                    visible: rootItem.isFlashingProfile || BatteryService.isCharging || BatteryService.isOnAC
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 350 } }
                }

                Text {
                    text: rootItem.percentage + "%"
                    font.family: rootItem.theme ? rootItem.theme.fontMain : "Inter"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    font.letterSpacing: -0.5
                    color: rootItem.theme ? rootItem.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Interactive MouseArea to cycle profiles on click or Hold to toggle One-Shot ──
        MouseArea {
            id: cardMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressAndHoldInterval: 750

            onPressAndHold: {
                if (BatteryService.isOneshotCharging) {
                    BatteryService.cancelOneshot();
                } else {
                    BatteryService.chargeFullOnce();
                }
                oneshotBurstAnim.restart();
            }

            onClicked: rootItem.cycleProfile()
        }
    }
}
