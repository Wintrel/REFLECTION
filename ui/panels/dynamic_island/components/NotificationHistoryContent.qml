import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var theme: null
    property var mprisPlayer: null
    property real islandHistoryW: 400
    property real islandHistoryH: 500
    
    // Dynamically calculate height based on content, clamped to max height
    property real computedHeight: {
        var h = 50 + 16; // Header height + margins
        if (State.GlobalStates.notificationHistory.count === 0) {
            h += 120; // Empty state height
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
    
    opacity: root.islandState === 4 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration : 250 } }
    
    // Ambient Void Background
    Components.Starfield {
        anchors.fill: parent
        starCount: 35
        starColor: root.theme ? root.theme.textMain : "#ffffff"
        opacity: 0.5 // Subtle so it doesn't distract from notifications
    }
    
    // Header
    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "Notifications"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 20
            font.bold: true
            font.letterSpacing: -0.5
            color: root.theme ? root.theme.textMain : "#FFF"
        }
        
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            
            // Music State Return Button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                visible: root.mprisPlayer !== null
                color: musicMa.containsMouse ? (root.theme ? Qt.rgba(root.theme.colorMusic.r, root.theme.colorMusic.g, root.theme.colorMusic.b, 0.2) : "#305611f8") : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: musicMa.containsMouse ? (root.theme ? root.theme.colorMusic : "#5611f8") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                MouseArea {
                    id: musicMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = 2; // Return to expanded music state
                        }
                    }
                }
            }
            
            // Clear All Button (sleek icon button)
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: clearMa.containsMouse ? (root.theme ? Qt.rgba(root.theme.colorNotification.r, root.theme.colorNotification.g, root.theme.colorNotification.b, 0.2) : "#30710cee") : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "delete_sweep"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: clearMa.containsMouse ? (root.theme ? root.theme.colorNotification : "#710cee") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                MouseArea {
                    id: clearMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        State.GlobalStates.notificationHistory.clear();
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = 0;
                        }
                    }
                }
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
        
        // Empty State
        Item {
            anchors.fill: parent
            visible: listView.count === 0
            
            Column {
                anchors.centerIn: parent
                spacing: 12
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "notifications_off"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 48
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.3) : "#40A6ADC8"
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
            property bool isVisible: root.islandState === 4
            opacity: isVisible ? 1 : 0
            transform: Translate {
                y: isVisible ? 0 : 20
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
                            asynchronous: false
                            visible: source != ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "notifications"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 24
                            color: root.theme ? root.theme.colorNotification : "#710cee"
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
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: (model.appName || "Notification").toUpperCase()
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                font.letterSpacing: 0.8
                                font.bold: true
                                color: root.theme ? root.theme.textSub : "#A6ADC8"
                            }
                            
                            // Close single button (only visible on hover)
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "close"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 16
                                color: closeMa.containsMouse ? (root.theme ? root.theme.colorNotification : "#710cee") : (root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8")
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
                        State.GlobalStates.notificationHistory.remove(index);
                    }
                    
                    // Allow the close button to receive clicks
                    z: -1
                }
            }
        }
    }
}
