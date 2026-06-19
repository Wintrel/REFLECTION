import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import QtMultimedia
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../components" as Components
import "./components" as IslandComponents

PanelWindow {
    id: islandWindow
    
    Core.Theme { id: theme }
    
    // Anchor only to the top, so it centers horizontally by default
    anchors {
        top: true
    }
    
    // Make sure the window acts as an overlay and doesn't take up literal screen space
    exclusiveZone: 0
    
    // Transparent background for the panel itself
    color: "transparent"
    
    // Lock the Wayland surface size to the maximum possible bounds to prevent resizing wobble
    implicitWidth: Math.max(theme.islandMaxW, theme.islandHistoryW || 0) + (2 * theme.radiusIsland)
    implicitHeight: Math.max(theme.islandMaxH, theme.islandHistoryH || 0)
    
    // Mask the input/visual region exactly to the opaque pixels of the container
    // This perfectly prevents the window from blocking clicks on the desktop!
    mask: Region {
        item: islandContainer
    }
    
    // State machine for the island: 0 = Minimized, 1 = Hovered, 2 = Expanded, 3 = Notification, 4 = History, 5 = OSD
    property int islandState: 0
    property int previousState: 0
    
    // OSD Mode: 0 = Volume, 1 = Brightness
    property int osdMode: 0
    
    // Auto-dismiss timer for notifications
    Timer {
        id: notifTimer
        interval: 5000 // 5 seconds
        onTriggered: {
            if (islandWindow.islandState === 3) {
                if (islandWindow.previousState === 2 || islandWindow.previousState === 4) {
                    islandWindow.islandState = islandWindow.previousState;
                } else {
                    islandWindow.islandState = islandShape.mouseArea.containsMouse ? 1 : 0;
                }
                islandWindow.previousState = 0;
            }
        }
    }
    
    // Auto-dismiss timer for OSD
    Timer {
        id: osdTimer
        interval: 2000 // 2 seconds
        onTriggered: {
            if (islandWindow.islandState === 5) {
                if (islandWindow.previousState === 2 || islandWindow.previousState === 4) {
                    islandWindow.islandState = islandWindow.previousState;
                } else {
                    islandWindow.islandState = islandShape.mouseArea.containsMouse ? 1 : 0;
                }
                islandWindow.previousState = 0;
            }
        }
    }
    
    Connections {
        target: VolumeService
        function onOsdTriggered() {
            if (islandWindow.islandState !== 5 && islandWindow.islandState !== 3) {
                islandWindow.previousState = islandWindow.islandState;
            }
            if (islandWindow.islandState !== 3) {
                // Don't override an active notification with a volume OSD
                islandWindow.osdMode = 0;
                islandWindow.islandState = 5;
                osdTimer.restart();
            }
        }
    }
    
    Connections {
        target: BrightnessService
        function onOsdTriggered() {
            if (islandWindow.islandState !== 5 && islandWindow.islandState !== 3) {
                islandWindow.previousState = islandWindow.islandState;
            }
            if (islandWindow.islandState !== 3) {
                // Don't override an active notification with a brightness OSD
                islandWindow.osdMode = 1;
                islandWindow.islandState = 5;
                osdTimer.restart();
            }
        }
    }
    
    // Play sound when a new notification arrives
    MediaPlayer {
        id: popSound
        source: "file:///usr/share/sounds/freedesktop/stereo/message.oga"
        audioOutput: AudioOutput { volume: 0.5 }
    }

    // Track the latest notification
    property var currentNotif: null
    
    NotificationServer {
        id: notificationServer
        onNotification: function() {
            var n = arguments.length > 0 ? arguments[0] : null;
            if (!n) return;
            
            // Create a pure JS copy of the notification data
            // This prevents QML from nulling the property if the C++ object is destroyed early
            var notifCopy = {
                summary: n.summary !== undefined ? n.summary : "",
                body: n.body !== undefined ? n.body : "",
                appName: n.appName !== undefined ? n.appName : "",
                image: n.image !== undefined ? n.image : "",
                icon: n.icon !== undefined ? n.icon : "",
                invokeDefaultAction: function() {
                    try { if (n) n.invokeDefaultAction(); } catch(e) {}
                },
                close: function() {
                    try { if (n) n.close(); } catch(e) {}
                }
            };
            
            // Store in Global History (functions are stripped, so just save data)
            var notifData = {
                summary: notifCopy.summary,
                body: notifCopy.body,
                appName: notifCopy.appName,
                image: notifCopy.image,
                icon: notifCopy.icon
            };
            State.GlobalStates.notificationHistory.insert(0, notifData);
            
            islandWindow.currentNotif = notifCopy;
            if (islandWindow.islandState !== 3) {
                islandWindow.previousState = islandWindow.islandState;
            }
            islandWindow.islandState = 3;
            notifTimer.restart();
            popSound.play();
        }
    }
    
    // MPRIS Player Tracking
    property int currentPlayerIndex: 0
    property var mprisPlayer: null
    
    Instantiator {
        id: playerInst
        model: Mpris.players
        delegate: QtObject { property var playerItem: modelData }
        function updatePlayer() {
            if (playerInst.count === 0) {
                islandWindow.mprisPlayer = null;
            } else {
                islandWindow.currentPlayerIndex = Math.min(islandWindow.currentPlayerIndex, playerInst.count - 1);
                islandWindow.mprisPlayer = playerInst.objectAt(islandWindow.currentPlayerIndex).playerItem;
            }
        }
        onObjectAdded: updatePlayer()
        onObjectRemoved: updatePlayer()
    }
    
    Item {
        id: islandContainer
        
        // Dynamically bind the container size to exactly the visible bounding box of the island
        width: islandShape.width + (2 * theme.radiusIsland)
        height: islandShape.height - theme.radiusIsland
        
        // Center inside the static PanelWindow
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        
        // The actual island container (Outer Bezel)
        Rectangle {
            id: islandShape
            property alias mouseArea: ma
            
            // Mouse area to trigger expansion (placed first so it sits behind the UI)
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                
                onEntered: {
                    if (islandWindow.islandState === 3) notifTimer.stop(); // Pause dismiss if hovering notification
                    else if (islandWindow.islandState === 5) osdTimer.stop();
                    else if (islandWindow.islandState !== 2 && islandWindow.islandState !== 4) islandWindow.islandState = 1
                }
                onExited: {
                    if (islandWindow.islandState === 3) notifTimer.restart(); // Resume dismiss timer
                    else if (islandWindow.islandState === 5) osdTimer.restart();
                    else if (islandWindow.islandState !== 2 && islandWindow.islandState !== 4) islandWindow.islandState = 0
                }
                onClicked: {
                    if (islandWindow.islandState === 3) {
                        // Dismiss notification
                        if (islandWindow.previousState === 2 || islandWindow.previousState === 4) {
                            islandWindow.islandState = islandWindow.previousState;
                        } else {
                            islandWindow.islandState = 1;
                        }
                        if (islandWindow.currentNotif) {
                            islandWindow.currentNotif.close();
                        }
                        islandWindow.previousState = 0;
                    } else if (islandWindow.islandState === 4) {
                        // If in history, clicking empty space does nothing or closes it
                        // Let's close it
                        islandWindow.islandState = 0;
                    } else if (islandWindow.islandState === 2) {
                        // If expanded, click to collapse back to hover state
                        islandWindow.islandState = containsMouse ? 1 : 0
                    } else {
                        // Click to expand fully
                        islandWindow.islandState = 2
                    }
                }
            }
            
            // Center horizontally in the transparent PanelWindow
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Position negatively to hide the top rounded corners and attach to the screen border
            y: -theme.radiusIsland
            
            // Smooth sizing based on state
            width: {
                if (islandState === 5) return theme.islandHoverW;
                if (islandState === 4) return theme.islandHistoryW;
                if (islandState === 3) return theme.islandNotifW;
                if (islandState === 2) return theme.islandMaxW;
                if (islandState === 1) return theme.islandHoverW;
                
                var hasM = islandWindow.mprisPlayer && islandWindow.mprisPlayer.isPlaying;
                var hasN = State.GlobalStates.notificationHistory.count > 0;
                return (hasM || hasN) ? theme.islandMinW : 120;
            }
            height: {
                var targetH = theme.islandMinH;
                if (islandState === 5) targetH = theme.islandHoverH;
                else if (islandState === 4) targetH = historyContent.computedHeight;
                else if (islandState === 3) targetH = theme.islandNotifH;
                else if (islandState === 2) targetH = theme.islandMaxH;
                else if (islandState === 1) targetH = theme.islandHoverH;
                return targetH + theme.radiusIsland;
            }
            
            radius: theme.radiusIsland
            color: theme.bgBezel // Outer bezel color
            
            // Smooth transition animations
            Behavior on width {
                NumberAnimation {
                    duration: theme.animDuration
                    easing.type: Easing.OutExpo
                }
            }
            
            Behavior on height {
                NumberAnimation {
                    duration: theme.animDuration
                    easing.type: Easing.OutExpo
                }
            }
            
            // The inner inset content area
            Rectangle {
                id: innerShape
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.bottomMargin: 4
                anchors.topMargin: theme.radiusIsland + 4 // Push down past the hidden top radius
                
                radius: parent.radius - 2 // Slightly smaller radius for nested look
                color: theme.bgInner
                
                clip: true
                
                IslandComponents.MinimizedContent {
                    anchors.fill: parent
                    islandState: islandWindow.islandState
                    mprisPlayer: islandWindow.mprisPlayer
                    theme: theme
                }
                
                IslandComponents.ExpandedContent {
                    islandState: islandWindow.islandState
                    mprisPlayer: islandWindow.mprisPlayer
                    theme: theme
                    islandMaxW: theme.islandMaxW
                    islandMaxH: theme.islandMaxH
                }
                
                IslandComponents.NotificationContent {
                    islandState: islandWindow.islandState
                    theme: theme
                    islandNotifW: theme.islandNotifW
                    islandNotifH: theme.islandNotifH
                    currentNotif: islandWindow.currentNotif
                }
                
                IslandComponents.NotificationHistoryContent {
                    id: historyContent
                    islandState: islandWindow.islandState
                    theme: theme
                    mprisPlayer: islandWindow.mprisPlayer
                    islandHistoryW: theme.islandHistoryW
                    islandHistoryH: theme.islandHistoryH
                }
                
                IslandComponents.OsdContent {
                    islandState: islandWindow.islandState
                    osdMode: islandWindow.osdMode
                    theme: theme
                    islandHoverW: theme.islandHoverW
                    islandHoverH: theme.islandHoverH
                }
            }
        } // End of islandShape
        
        IslandComponents.IslandFillets {
            islandShape: islandShape
            radiusIsland: theme.radiusIsland
            bgBezel: theme.bgBezel
        }
    } // End of islandContainer
}
