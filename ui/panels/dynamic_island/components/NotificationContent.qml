import "../../../../core/state" as State
import QtQuick
import "../../../../core" as Core

Item {
    id: root
    
    signal dismissRequested()
    
    property int islandState: State.IslandState.idle
    property var theme: null
    property real islandNotifW: 400
    property real islandNotifH: 80
    
    width: islandNotifW - 32
    height: islandNotifH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandNotifH - height) / 2
    
    property bool isNotif: root.islandState === State.IslandState.notification
    opacity: isNotif ? 1 : 0
    visible: opacity > 0
    scale: isNotif ? 1.0 : 0.94
    layer.enabled: true
    Behavior on opacity { 
        NumberAnimation { 
            duration: root.isNotif ? (root.theme ? root.theme.durationContentIn : 220) : (root.theme ? root.theme.durationContentOut : 120)
            easing.type: root.isNotif ? Easing.OutQuad : Easing.InQuad 
        } 
    }
    MouseArea {
        id: spatialGestureArea
        anchors.fill: parent
        z: -1
        
        property real startX: 0
        property real startY: 0
        property bool isDragging: false
        
        onPressed: function(mouse) {
            startX = mouse.x;
            startY = mouse.y;
            isDragging = false;
        }
        
        onPositionChanged: function(mouse) {
            var dx = mouse.x - startX;
            var dy = mouse.y - startY;
            if (Math.abs(dx) > 15 || Math.abs(dy) > 15) {
                isDragging = true;
            }
        }
        
        onReleased: function(mouse) {
            if (isDragging) {
                var dx = mouse.x - startX;
                var dy = mouse.y - startY;
                var absX = Math.abs(dx);
                var absY = Math.abs(dy);
                
                if (absX > absY && absX > 35 && dx > 0) {
                    // Swipe Right -> Dismiss Notification
                    root.dismissRequested();
                } else if (absY > absX && absY > 25 && dy < 0) {
                    // Swipe Up -> Dismiss Notification
                    root.dismissRequested();
                }
            }
        }
        
        onClicked: function(mouse) {
            if (!isDragging) {
                // Click dismisses notification
                root.dismissRequested();
            }
        }
        
        property real lastWheelGestureTime: 0
        
        onWheel: function(wheel) {
            var now = Date.now();
            if (now - lastWheelGestureTime < 320) return;
            
            var dx = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x;
            var dy = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y;
            var absX = Math.abs(dx);
            var absY = Math.abs(dy);
            
            if (absX > absY && absX > 25 && dx > 0) {
                lastWheelGestureTime = now;
                // Two-finger trackpad swipe right -> Dismiss Notification
                root.dismissRequested();
            } else if (absY > absX && absY > 25 && dy < 0) {
                lastWheelGestureTime = now;
                // Two-finger trackpad swipe up -> Dismiss Notification
                root.dismissRequested();
            }
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: Easing.OutCubic
        }
    }
    
    property bool isLocked: false
    property var currentNotif: null
    onCurrentNotifChanged: {
        console.log("NotificationContent.qml: currentNotif changed to", currentNotif);
        if (currentNotif) {
            console.log("NotificationContent.qml: summary is", currentNotif.summary);
        }
    }
    
    // Layout
    Row {
        anchors.fill: parent
        spacing: 16
        
        // App Icon or Image
        Rectangle {
            id: iconRect
            width: 48
            height: 48
            radius: 12
            color: root.theme ? Qt.rgba(root.theme.accentNotification.r, root.theme.accentNotification.g, root.theme.accentNotification.b, 0.15) : "#20710cee"
            anchors.verticalCenter: parent.verticalCenter
            
            property bool isVisible: root.islandState === State.IslandState.notification
            opacity: (root.islandState === State.IslandState.notification) ? 1 : 0
            transform: Translate {
                y: (root.islandState === State.IslandState.notification) ? 0 : -5
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
            
            // Notification image or icon
            Image {
                anchors.fill: parent
                anchors.margins: 4
                function getSource() {
                    if (!root.currentNotif) return "";
                    var img = root.currentNotif.image || "";
                    var icn = root.currentNotif.icon || "";
                    
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
                source: getSource()
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: source != ""
            }
            
            // Fallback icon
            Text {
                anchors.centerIn: parent
                text: "notifications"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 28
                color: root.theme ? root.theme.accentNotification : "#710cee"
                visible: !parent.children[0].visible // If image is hidden
            }
        }
        
        // Text Content
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - iconRect.width - 16
            spacing: 2
            
            property bool isVisible: root.islandState === State.IslandState.notification
            opacity: (root.islandState === State.IslandState.notification) ? 1 : 0
            transform: Translate {
                y: (root.islandState === State.IslandState.notification) ? 0 : 10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
            
            Text {
                text: root.currentNotif ? (root.currentNotif.appName || "Notification").toUpperCase() : "NOTIFICATION"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.letterSpacing: 0.5
                font.bold: true
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                width: parent.width
                elide: Text.ElideRight
            }
            
            Text {
                text: {
                    if (!root.currentNotif) return "No Notification";
                    if (root.isLocked) return "New Notification";
                    return root.currentNotif.summary;
                }
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 15
                font.bold: true
                color: root.theme ? root.theme.textMain : "#FFF"
                width: parent.width
                elide: Text.ElideRight
            }
            
            Text {
                text: root.isLocked ? "Content hidden for privacy" : (root.currentNotif ? root.currentNotif.body : "")
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 13
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                width: parent.width
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
        }
    }
    
    // Interactive area to dismiss
    MouseArea {
        anchors.fill: parent
        cursorShape: root.isLocked ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: {
            if (root.isLocked) return;
            if (root.currentNotif) {
                // Close the notification in the Quickshell server
                // Quickshell notification objects usually have a close() or dismiss() or similar method,
                // or we can just dismiss it by clearing our state (handled by root DynamicIsland)
                root.currentNotif.invokeDefaultAction(); // Attempt to invoke action if they click
                root.currentNotif.close(); // Ask the server to dismiss the notification
            }
            root.dismissRequested();
        }
    }
}
