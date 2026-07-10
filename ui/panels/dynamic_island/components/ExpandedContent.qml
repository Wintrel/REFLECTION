import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null
    property real islandMaxW: 0
    property real islandMaxH: 0
    
    property real lastMprisAction: 0
    property bool forceFillAnimation: false
    
    function canSendMpris() {
        var now = Date.now();
        if (now - lastMprisAction > 400) {
            lastMprisAction = now;
            return true;
        }
        return false;
    }
    
    width: islandMaxW - 32
    height: islandMaxH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandMaxH - height) / 2
    
    opacity: root.islandState === 2 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration : 250 } }
    
    // Background Visualizer
    Components.Visualizer {
        anchors.fill: parent
        anchors.margins: -8
        isPlaying: root.islandState === 2
        accentColor: root.theme ? root.theme.colorMusic : "#5611f8"
    }
    
    // Top Sliver (Icons)
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
                id: notifIcon
                anchors.centerIn: parent
                text: "notifications"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.theme ? root.theme.colorNotification : "#710cee"
                scale: notifMa.pressed ? 0.9 : (notifMa.containsMouse ? 1.1 : 1)
                opacity: notifMa.pressed ? 0.7 : 1
                Behavior on scale { NumberAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: notifMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = 4;
                    }
                }
            }
        }
        
        Item {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: batteryRow.width
            height: batteryRow.height
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = 9; // Switch to Battery View
                    }
                }
            }
            
            Row {
                id: batteryRow
                spacing: 6
                Text {
                    text: BatteryService.percentage + "%"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    color: root.theme ? root.theme.textMain : "#FFF"
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
                    color: BatteryService.percentage > 20 || BatteryService.isCharging ? (root.theme ? root.theme.textMain : "#FFF") : "#F38BA8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    
    // Main Content
    Item {
        anchors.top: topSliver.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        
        Rectangle {
            id: albumArt
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 60
            height: 60
            radius: 8
            color: "#313244"
            
            Image {
                id: coverImg
                anchors.fill: parent
                source: root.mprisPlayer ? (root.mprisPlayer.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                visible: source != ""
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle { width: 60; height: 60; radius: 8 }
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                visible: !coverImg.visible
            }
        }
        
        Column {
            anchors.left: albumArt.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "No Media") : "No Media"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 16
                font.bold: true
                color: root.theme ? root.theme.textMain : "#FFF"
                width: 250
                elide: Text.ElideRight
            }
            Text {
                text: root.mprisPlayer ? (root.mprisPlayer.trackArtist || "") : ""
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                width: 250
                elide: Text.ElideRight
            }
            // Source Indicator
            Item {
                width: sourceRow.width
                height: sourceRow.height
                visible: root.mprisPlayer && root.mprisPlayer.identity
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.cyclePlayer();
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: 4
                        color: parent.containsMouse ? Qt.rgba(255,255,255,0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                Row {
                    id: sourceRow
                    spacing: 4
                    anchors.centerIn: parent
                    
                    Text {
                        text: "cast"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.accentPrimary : "#00FFCC"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.mprisPlayer ? (root.mprisPlayer.identity || "Unknown Source").toUpperCase() : ""
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 0.5
                        color: root.theme ? root.theme.accentPrimary : "#00FFCC"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16
            
            Text { 
                id: btnPrev
                text: "skip_previous"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 32
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter 
                
                scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.1 : 1)
                opacity: maPrev.pressed ? 0.6 : (maPrev.containsMouse ? 0.8 : 1)
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
                
                MouseArea { 
                    id: maPrev
                    anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.mprisPlayer && root.canSendMpris()) {
                            var threshold = root.mprisPlayer.length > 10000 ? 3000000 : 3;
                            if (root.mprisPlayer.position > threshold && root.mprisPlayer.canSeek) {
                                root.mprisPlayer.position = 0;
                            } else {
                                root.mprisPlayer.previous();
                            }
                        }
                    }
                }
            }
            
            Text { 
                id: btnPlay
                text: (root.mprisPlayer && root.mprisPlayer.isPlaying) ? "pause_circle" : "play_circle"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 42
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter 
                
                scale: maPlay.pressed ? 0.85 : (maPlay.containsMouse ? 1.05 : 1)
                opacity: maPlay.pressed ? 0.6 : (maPlay.containsMouse ? 0.8 : 1)
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
                
                MouseArea { 
                    id: maPlay
                    anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.mprisPlayer && root.canSendMpris()) root.mprisPlayer.togglePlaying() 
                }
            }
            
            Text { 
                id: btnNext
                text: "skip_next"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 32
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter 
                
                scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.1 : 1)
                opacity: maNext.pressed ? 0.6 : (maNext.containsMouse ? 0.8 : 1)
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 650 } }
                
                MouseArea { 
                    id: maNext
                    anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.mprisPlayer && root.canSendMpris()) {
                            root.forceFillAnimation = true;
                            root.mprisPlayer.next();
                        }
                    }
                }
            }
        }
        
        Rectangle {
            id: progressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 4
            
            height: (maProgress.containsMouse || isDragging) ? 10 : 6
            radius: height / 2
            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            color: Qt.rgba(0, 0, 0, 0.5)
            
            property bool isDragging: false
            property real dragRatio: 0
            
            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                color: root.theme ? root.theme.colorMusic : "#5611f8"
                
                property real computedWidth: {
                    if (progressBar.isDragging) return parent.width * progressBar.dragRatio;
                    return root.mprisPlayer && root.mprisPlayer.length > 0 ? (parent.width * (root.mprisPlayer.position / root.mprisPlayer.length)) : 0;
                }
                width: computedWidth
                
                Behavior on width {
                    id: widthBehavior
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
                
                property real lastWidth: 0
                onComputedWidthChanged: {
                    if (progressBar.isDragging) {
                        lastWidth = computedWidth;
                        return;
                    }
                    var naturalEndSkip = (lastWidth > parent.width * 0.8 && computedWidth < parent.width * 0.2);
                    var manualNextSkip = root.forceFillAnimation;
                    
                    if (naturalEndSkip || manualNextSkip) {
                        root.forceFillAnimation = false;
                        widthBehavior.enabled = false;
                        trackChangeAnim.start();
                    }
                    lastWidth = computedWidth;
                }
                
                SequentialAnimation {
                    id: trackChangeAnim
                    NumberAnimation {
                        target: fillRect
                        property: "width"
                        to: progressBar.width
                        duration: 650
                        easing.type: Easing.OutQuad
                    }
                    PropertyAction {
                        target: fillRect
                        property: "width"
                        value: 0
                    }
                    NumberAnimation {
                        target: fillRect
                        property: "width"
                        to: fillRect.computedWidth
                        duration: 650
                        easing.type: Easing.OutCubic
                    }
                    onStopped: {
                        widthBehavior.enabled = true;
                        fillRect.width = Qt.binding(function() { return fillRect.computedWidth; });
                    }
                }
            }
            
            MouseArea {
                id: maProgress
                anchors.fill: parent
                anchors.margins: -10
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                function updateRatio(mouse) {
                    var localX = mouse.x + anchors.leftMargin
                    var ratio = Math.max(0, Math.min(1, localX / progressBar.width))
                    progressBar.dragRatio = ratio
                }
                
                onPressed: (mouse) => {
                    progressBar.isDragging = true
                    updateRatio(mouse)
                }
                onPositionChanged: (mouse) => {
                    if (progressBar.isDragging) updateRatio(mouse)
                }
                onReleased: (mouse) => {
                    if (progressBar.isDragging) {
                        updateRatio(mouse)
                        progressBar.isDragging = false
                        if (root.mprisPlayer && root.mprisPlayer.length > 0 && root.mprisPlayer.canSeek) {
                            root.mprisPlayer.position = progressBar.dragRatio * root.mprisPlayer.length
                        }
                    }
                }
            }
        }
    }
}
