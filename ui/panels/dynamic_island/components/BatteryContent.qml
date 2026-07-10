import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var theme: null
    property real islandBatteryW: 0
    property real islandBatteryH: 0
    
    // Contextual battery colors
    readonly property color chargingColor: "#00FFCC"
    readonly property color oneshotColor: root.theme ? root.theme.colorSystemShimmer : "#0051ff" // Electric blue override
    readonly property color acColor: "#89B4FA"        // On AC but not actively charging (Full / Limit)
    
    // Derived active charging color (gold during oneshot, cyan otherwise)
    readonly property color activeChargingColor: BatteryService.isOneshotCharging ? oneshotColor : chargingColor
    
    // Smooth color interpolation helper
    function lerpColor(a, b, t) {
        return Qt.rgba(
            a.r + (b.r - a.r) * t,
            a.g + (b.g - a.g) * t,
            a.b + (b.b - a.b) * t,
            1.0
        );
    }
    
    // Dynamic bar color: smooth gradient across battery level
    //   Charging     →  Cyan (#00FFCC)
    //   On AC (idle) →  Soft blue (#89B4FA)
    //   100–60%      →  Green (#4ADE80) to Yellow (#FACC15)
    //    60–30%      →  Yellow (#FACC15) to Orange (#F97316)
    //    30–10%      →  Orange (#F97316) to Red (#EF4444)
    //    10– 0%      →  Deep Red (#DC2626)
    readonly property color barColor: {
        if (BatteryService.isCharging) return activeChargingColor;
        if (BatteryService.isOnAC) return acColor;
        var pct = BatteryService.percentage;
        if (pct > 60) return lerpColor(Qt.color("#FACC15"), Qt.color("#4ADE80"), (pct - 60) / 40.0);
        if (pct > 30) return lerpColor(Qt.color("#F97316"), Qt.color("#FACC15"), (pct - 30) / 30.0);
        if (pct > 10) return lerpColor(Qt.color("#EF4444"), Qt.color("#F97316"), (pct - 10) / 20.0);
        return Qt.color("#DC2626");
    }
    
    // Wattage-based color for power draw text
    //   < 8W   →  Efficient green
    //   8–20W  →  Moderate yellow
    //   20–35W →  High orange
    //   > 45W  →  Heavy red
    readonly property color wattageColor: {
        var w = Math.abs(BatteryService.smoothWattage);
        if (w < 8)  return "#4ADE80";
        if (w < 20) return lerpColor(Qt.color("#4ADE80"), Qt.color("#FACC15"), (w - 8) / 12.0);
        if (w < 45) return lerpColor(Qt.color("#FACC15"), Qt.color("#F97316"), (w - 20) / 15.0);
        return "#EF4444";
    }
    
    width: islandBatteryW - 32
    height: islandBatteryH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandBatteryH - height) / 2
    
    opacity: root.islandState === 9 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration : 250 } }
    
    // ── Top Sliver ──
    Item {
        id: topSliver
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 20
        
        Item {
            anchors.left: parent.left
            width: 32
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                id: musicIcon
                anchors.centerIn: parent
                text: "music_note"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.theme ? root.theme.colorMusic : "#5611f8"
                scale: musicMa.pressed ? 0.9 : (musicMa.containsMouse ? 1.1 : 1)
                opacity: musicMa.pressed ? 0.7 : 1
                Behavior on scale { NumberAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: musicMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = 2; // Switch back to music
                    }
                }
            }
        }
        
        Row {
            anchors.right: parent.right
            spacing: 6
            Text {
                text: BatteryService.percentage + "%"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 13
                color: root.theme ? root.theme.accentPrimary : "#ff9900"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: {
                    if (BatteryService.isCharging) return "battery_charging_full";
                    if (BatteryService.percentage > 80) return "battery_full";
                    if (BatteryService.percentage > 60) return "battery_5_bar";
                    if (BatteryService.percentage > 40) return "battery_4_bar";
                    if (BatteryService.percentage > 20) return "battery_3_bar";
                    if (BatteryService.percentage > 10) return "battery_1_bar";
                    return "battery_alert";
                }
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.theme ? root.theme.accentPrimary : "#ff9900"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    // ── Main Content ──
    Item {
        anchors.top: topSliver.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        
        // ── Hero: Large Percentage + Status ──
        Item {
            id: heroSection
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34
            
            Text {
                id: bigPercentage
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: BatteryService.percentage + "%"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: BatteryService.isOneshotCharging ? root.oneshotColor : (root.theme ? root.theme.textMain : "#CDD6F4")
                Behavior on color { ColorAnimation { duration: 500 } }
            }
            
            Row {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                spacing: 6
                
                Text {
                    text: {
                        if (BatteryService.isOneshotCharging) return "One-Shot Override";
                        if (BatteryService.isCharging) return "Charging";
                        if (BatteryService.isOnAC) {
                            if (BatteryService.status === "Full") return "Fully Charged";
                            return "Plugged In";
                        }
                        return "On Battery";
                    }
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: {
                        if (BatteryService.isOneshotCharging) return root.oneshotColor;
                        if (BatteryService.isCharging) return root.chargingColor;
                        if (BatteryService.isOnAC) return root.acColor;
                        return root.theme ? root.theme.textSub : "#A6ADC8";
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 400 } }
                }
                
                Text {
                    text: {
                        if (BatteryService.isCharging) return "bolt";
                        if (BatteryService.isOnAC) return "power";
                        return "battery_horiz_050";
                    }
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: {
                        if (BatteryService.isOneshotCharging) return root.oneshotColor;
                        if (BatteryService.isCharging) return root.chargingColor;
                        if (BatteryService.isOnAC) return root.acColor;
                        return root.theme ? root.theme.textSub : "#A6ADC8";
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 400 } }
                }
            }
        }
        
        // ── Horizontal Battery Bar ──
        Item {
            id: batteryBarContainer
            anchors.top: heroSection.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            height: 14
            
            // Track
            Rectangle {
                id: barTrack
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            
            // Oneshot pulsing glow on the track
            Rectangle {
                id: oneshotGlow
                anchors.fill: parent
                anchors.margins: -2
                radius: (height + 4) / 2
                color: "transparent"
                border.width: 1.5
                border.color: root.oneshotColor
                visible: BatteryService.isOneshotCharging && root.islandState === 9
                opacity: 0
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: BatteryService.isOneshotCharging && root.islandState === 9
                    NumberAnimation { from: 0; to: 0.6; duration: 1200; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.6; to: 0; duration: 1200; easing.type: Easing.InOutSine }
                }
            }
            
            // Fill
            Rectangle {
                id: barFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (BatteryService.percentage / 100.0)
                radius: parent.height / 2
                color: root.barColor
                clip: true
                
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 400 } }
                
                // Charging shimmer sweep (faster + brighter during oneshot)
                Rectangle {
                    id: shimmer
                    visible: BatteryService.isCharging && root.islandState === 9
                    width: BatteryService.isOneshotCharging ? 70 : 50
                    height: parent.height
                    radius: parent.radius
                    
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, BatteryService.isOneshotCharging ? 0.45 : 0.3) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: BatteryService.isCharging && root.islandState === 9
                        NumberAnimation {
                            from: -70
                            to: barFill.width + 10
                            duration: BatteryService.isOneshotCharging ? 1500 : 2500
                            easing.type: Easing.InOutSine
                        }
                        PauseAnimation { duration: BatteryService.isOneshotCharging ? 300 : 600 }
                    }
                }
            }
        }
        
        // ── Stats Rows ──
        Column {
            id: statsColumn
            anchors.top: batteryBarContainer.bottom
            anchors.topMargin: 14
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8
            
            // Row 1: Time remaining + Power draw
            Item {
                width: parent.width
                height: 18
                
                Row {
                    anchors.left: parent.left
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: "schedule"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: BatteryService.smoothTimeRemaining !== "" ? BatteryService.smoothTimeRemaining + (BatteryService.smoothTimeLabel !== "" ? " " + BatteryService.smoothTimeLabel : "") : "Calculating..."
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Row {
                    anchors.right: parent.right
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: "electric_bolt"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: root.wattageColor
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 400 } }
                    }
                    Text {
                        text: {
                            if (BatteryService.isOnAC && BatteryService.smoothWattage < 2.0) return "Idle";
                            return BatteryService.smoothWattage.toFixed(1) + " W";
                        }
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: root.wattageColor
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 400 } }
                    }
                }
            }
            
            // Row 2: Health + Charge limit
            Item {
                width: parent.width
                height: 22
                
                Row {
                    anchors.left: parent.left
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: "health_and_safety"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Health " + BatteryService.health + "%"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Charge limit segmented toggle
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    
                    Text {
                        text: "battery_saver"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Limit"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    // Segmented control: 60% | Charge Full
                    Rectangle {
                        width: segRow.width + 6
                        height: 22
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.06)
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Row {
                            id: segRow
                            anchors.centerIn: parent
                            spacing: 2
                            
                            // 60% segment
                            Rectangle {
                                property bool isActive: BatteryService.batteryLimit <= 60 && !BatteryService.isOneshotCharging
                                width: 36
                                height: 18
                                radius: 4
                                color: isActive ? (root.theme ? root.theme.accentPrimary : "#ff9900") : "transparent"
                                Behavior on color { ColorAnimation { duration: 200 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "60%"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: parent.isActive ? "#000" : (root.theme ? root.theme.textSub : "#A6ADC8")
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: BatteryService.setChargeLimit(60)
                                }
                            }
                            
                            // Charge Full (oneshot) segment
                            Rectangle {
                                property bool isActive: BatteryService.isOneshotCharging
                                width: chargePill.width + 10
                                height: 18
                                radius: 4
                                color: isActive ? root.chargingColor : "transparent"
                                Behavior on color { ColorAnimation { duration: 200 } }
                                
                                Row {
                                    id: chargePill
                                    anchors.centerIn: parent
                                    spacing: 3
                                    
                                    Text {
                                        text: parent.parent.isActive ? (chargeMa.containsMouse ? "close" : "bolt") : "bolt"
                                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                        font.pixelSize: 11
                                        color: parent.parent.isActive ? "#000" : (root.theme ? root.theme.textSub : "#A6ADC8")
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                    Text {
                                        text: parent.parent.isActive ? (chargeMa.containsMouse ? "Cancel" : "Charging...") : "Full Once"
                                        font.family: root.theme ? root.theme.fontMain : "Inter"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: parent.parent.isActive ? "#000" : (root.theme ? root.theme.textSub : "#A6ADC8")
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }
                                
                                MouseArea {
                                    id: chargeMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!BatteryService.isOneshotCharging) {
                                            BatteryService.chargeFullOnce();
                                        } else {
                                            BatteryService.cancelOneshot();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ── Power Profile Pills ──
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            
            Repeater {
                model: [
                    { label: "Quiet", icon: "eco" },
                    { label: "Balanced", icon: "balance" },
                    { label: "Performance", icon: "bolt" }
                ]
                
                delegate: Rectangle {
                    required property var modelData
                    
                    property bool isActive: BatteryService.asusProfile === modelData.label
                    property bool isHovered: pillMa.containsMouse
                    property bool isPressed: pillMa.pressed
                    
                    width: pillRow.width + 20
                    height: 28
                    radius: 14
                    
                    color: {
                        if (isActive) return root.theme ? root.theme.textMain : "#FFF";
                        if (isPressed) return Qt.rgba(1, 1, 1, 0.15);
                        if (isHovered) return Qt.rgba(1, 1, 1, 0.1);
                        return Qt.rgba(1, 1, 1, 0.04);
                    }
                    border.width: isActive ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    
                    scale: isPressed ? 0.96 : (isHovered && !isActive ? 1.03 : 1)
                    
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    
                    Row {
                        id: pillRow
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            text: modelData.icon
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 14
                            color: isActive ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        Text {
                            text: modelData.label
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            font.weight: isActive ? Font.Bold : Font.Normal
                            color: isActive ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    
                    MouseArea {
                        id: pillMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BatteryService.setAsusProfile(modelData.label)
                    }
                }
            }
        }
    }
}
