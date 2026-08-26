import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: State.IslandState.idle
    property var theme: null
    property var mprisPlayer: null
    property real islandHistoryW: 400
    property real islandHistoryH: 500
    
    // Dynamically calculate height based on content, clamped to max height
    property real computedHeight: {
        var h = 28 + 16 + 16; // Header height (28) + margins
        if (State.GlobalStates.notificationHistory.count === 0) {
            h += 200; // Empty state height
        } else {
            h += listView.contentHeight + 16;
        }
        return Math.min(islandHistoryH, Math.max(150, h));
    }
    
    width: islandHistoryW - 32
    height: computedHeight - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 16
    
    property bool isHistory: root.islandState === State.IslandState.notificationHistory
    opacity: isHistory ? 1 : 0
    visible: opacity > 0
    scale: isHistory ? 1.0 : 0.95
    layer.enabled: true
    Behavior on opacity { 
        NumberAnimation { 
            duration: root.isHistory ? (root.theme ? root.theme.durationContentIn : 220) : (root.theme ? root.theme.durationContentOut : 120)
            easing.type: root.isHistory ? Easing.OutQuad : Easing.InQuad 
        } 
    }
    // Background click/drag handlers that don't block UI buttons
    TapHandler {
        onTapped: {
            if (typeof islandWidget !== "undefined") {
                islandWidget.islandState = State.IslandState.idle;
            }
        }
    }

    DragHandler {
        target: null
        xAxis.enabled: true
        yAxis.enabled: true
        onActiveChanged: {
            if (!active) {
                var dx = translation.x;
                var dy = translation.y;
                var absX = Math.abs(dx);
                var absY = Math.abs(dy);
                
                if (absX > absY && absX > 35) {
                    if (dx < 0) {
                        // Swipe Left -> Back to Media
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.expanded;
                        }
                    }
                } else if (absY > absX && absY > 30) {
                    if (dy < 0) {
                        // Swipe Up -> Collapse to Pill
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.idle;
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: spatialGestureArea
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.NoButton
        
        property real accumulatedX: 0
        property real accumulatedY: 0
        property real lastWheelEventTime: 0
        property real lastGestureActionTime: 0
        
        onWheel: function(wheel) {
            var now = Date.now();
            
            if (now - lastGestureActionTime < 400) {
                lastWheelEventTime = now;
                return;
            }
            
            if (now - lastWheelEventTime > 250) {
                accumulatedX = 0;
                accumulatedY = 0;
            }
            lastWheelEventTime = now;
            
            var dx = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x;
            var dy = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y;
            
            accumulatedX += dx;
            accumulatedY += dy;
            
            var absX = Math.abs(accumulatedX);
            var absY = Math.abs(accumulatedY);
            var threshold = 60;
            
            if (absX > absY && absX > threshold) {
                if (accumulatedX < 0) {
                    lastGestureActionTime = now;
                    // Two-finger trackpad swipe left -> Return to Media
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.expanded;
                    }
                }
                accumulatedX = 0;
                accumulatedY = 0;
            } else if (absY > absX && absY > threshold) {
                if (accumulatedY < 0) {
                    lastGestureActionTime = now;
                    // Two-finger trackpad swipe up -> Collapse to Pill
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.idle;
                    }
                }
                accumulatedX = 0;
                accumulatedY = 0;
            }
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: Easing.OutCubic
        }
    }
    
    // Ambient Void Background
    Components.Starfield {
        anchors.fill: parent
        starCount: 35
        starColor: root.theme ? root.theme.textMain : "#ffffff"
        opacity: 0.5 // Subtle so it doesn't distract from notifications
    }
    
    // Universal TopBar
    IslandTopBar {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        islandState: root.islandState
        theme: root.theme
        title: "Notifications"
        showClearAllButton: true
        showCloseButton: true
        
        onClearAllClicked: {
            State.GlobalStates.notificationHistory.clear();
            if (typeof islandWidget !== "undefined") {
                islandWidget.islandState = State.IslandState.idle;
            }
        }
    }
    
    // History List
    ListView {
        id: listView
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        clip: true
        spacing: 12
        model: State.GlobalStates.notificationHistory
        
        property bool isVisible: root.islandState === State.IslandState.notificationHistory
        opacity: (root.islandState === State.IslandState.notificationHistory) ? 1 : 0
        transform: Translate {
            y: (root.islandState === State.IslandState.notificationHistory) ? 0 : 10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        Behavior on contentY {
            enabled: !listView.dragging && !listView.flicking
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        
        // Empty State
        Item {
            anchors.fill: parent
            visible: listView.count === 0
            
            Column {
                anchors.centerIn: parent
                spacing: 12
                
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 96
                    height: 96
                    radius: 48 // Perfect circle for the empty state
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.1) : "#10A6ADC8"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "notifications_off"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 48
                        color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.4) : "#60A6ADC8"
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "You're all caught up"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.7) : "#B0A6ADC8"
                }
            }
        }
        
        delegate: Item {
            id: delegateItem
            width: ListView.view.width
            height: Math.max(iconRect.height, col.height) + 32
            
            // Simple staggered slide-up and fade-in transition
            property bool isVisible: root.islandState === State.IslandState.notificationHistory
            opacity: (root.islandState === State.IslandState.notificationHistory) ? 1 : 0
            transform: Translate {
                y: (root.islandState === State.IslandState.notificationHistory) ? 0 : 20
                Behavior on y {
                    SequentialAnimation {
                        PauseAnimation { duration: delegateItem.isVisible ? index * 40 : 0 }
                        NumberAnimation { duration: 400; easing.type: Easing.OutExpo }
                    }
                }
            }
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: delegateItem.isVisible ? index * 40 : 0 }
                    NumberAnimation { duration: 300; easing.type: Easing.OutSine }
                }
            }
            
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                radius: 16
                color: maItem.containsMouse ? (root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.08) : "#14FFFFFF") : (root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.04) : "#0AFFFFFF")
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // Icon
                    Rectangle {
                        id: iconRect
                        anchors.verticalCenter: parent.verticalCenter
                        width: 44
                        height: 44
                        radius: 12
                        color: root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.05) : "#0DFFFFFF"
                        
                        Image {
                            anchors.fill: parent
                            anchors.margins: 6
                            source: {
                                var img = model.image || "";
                                var icn = model.icon || "";
                                if (img) {
                                    if (img.indexOf("://") === -1 && !img.startsWith("/")) return "image://icon/" + img;
                                    return img;
                                }
                                if (icn) {
                                    if (icn.indexOf("://") === -1 && !icn.startsWith("/")) return "image://icon/" + icn;
                                    return icn;
                                }
                                return "";
                            }
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: source != ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "notifications"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 24
                            color: root.theme ? root.theme.accentNotification : "#710cee"
                            visible: !parent.children[0].visible
                        }
                    }
                    
                    // Text Content/
                    Column {
                        id: col
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - iconRect.width - 16
                        spacing: 4
                        
                        Item {
                            width: parent.width
                            height: 16
                            
                            Text {
                                id: appNameText
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: (model.appName || "Notification").toUpperCase()
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                font.letterSpacing: 0.8
                                font.bold: true
                                color: root.theme ? root.theme.textSub : "#A6ADC8"
                            }
                            
                            // Timestamp
                            Text {
                                anchors.left: appNameText.right
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    if (model.time) {
                                        var d = new Date(model.time);
                                        return ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
                                    }
                                    return "Just now";
                                }
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 10
                                color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8"
                            }
                            
                            // Close single button (only visible on hover)
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "close"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 16
                                color: closeMa.containsMouse ? (root.theme ? root.theme.accentNotification : "#710cee") : (root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8")
                                opacity: maItem.containsMouse ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                
                                MouseArea {
                                    id: closeMa
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        State.GlobalStates.notificationHistory.remove(index);
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: model.summary || "No Notification"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 15
                            font.bold: true
                            color: root.theme ? root.theme.textMain : "#FFF"
                            width: parent.width - 24
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: model.body || ""
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                            width: parent.width - 12
                            elide: Text.ElideRight
                            maximumLineCount: 3
                            wrapMode: Text.Wrap
                            visible: text !== ""
                        }
                    }
                }
                
                // Interaction: Dismisses cleanly (Apple-style)
                MouseArea {
                    id: maItem
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof State.GlobalStates.notificationHistory.invoke === "function") {
                            State.GlobalStates.notificationHistory.invoke(index);
                        } else {
                            State.GlobalStates.notificationHistory.remove(index);
                        }
                    }
                    
                    // Allow the close button to receive clicks
                    z: -1
                }
            }
        }
    }
}
