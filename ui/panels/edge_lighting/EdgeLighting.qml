import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../components" as Components
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/monitors"

Scope {
    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: edgeWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region { item: Item {} } // Pass all clicks through to desktop
            color: "transparent"

            Core.Theme { id: theme }

            property bool isActive: false
            property color currentColor: theme.accentNotification
            
            Connections {
                target: State.GlobalStates
                function onNotificationTriggered() {
                    console.log("EdgeLighting: notificationTriggered signal received!");
                    if (edgeWindow.isPromptActive) {
                        console.log("EdgeLighting: prompt is active, ignoring notification");
                        return;
                    }
                    edgeWindow.currentColor = theme.accentNotification;
                    edgeWindow.isActive = true;
                    console.log("EdgeLighting: isActive set to true (notification), currentColor:", edgeWindow.currentColor);
                    hideTimer.restart();
                }
            }

            property bool isPromptActive: false

            Connections {
                target: PromptService
                function onPromptRequested() {
                    console.log("EdgeLighting: promptRequested signal received!");
                    edgeWindow.isPromptActive = true;
                    edgeWindow.currentColor = theme.accentPrimary;
                    edgeWindow.isActive = true;
                    hideTimer.stop();
                }
                function onCanceled() {
                    console.log("EdgeLighting: prompt canceled");
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
                function onSubmitted() {
                    console.log("EdgeLighting: prompt submitted");
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
            }

            Connections {
                target: PolkitAuthService
                function onPolkitRequestStarted() {
                    console.log("EdgeLighting: polkitRequestStarted signal received!");
                    edgeWindow.isPromptActive = true;
                    edgeWindow.currentColor = "#ff4444"; // Aggressive red for Polkit
                    edgeWindow.isActive = true;
                    hideTimer.stop();
                }
                function onPolkitRequestFinished() {
                    console.log("EdgeLighting: polkitRequestFinished");
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
            }
            
            onIsActiveChanged: {
                console.log("EdgeLighting isActive changed to:", isActive, "dimensions:", width, "x", height, "currentColor:", currentColor);
            }

            Timer {
                id: hideTimer
                interval: 5000 // 5 seconds of edge glow.
                onTriggered: {
                    if (!edgeWindow.isPromptActive) {
                        edgeWindow.isActive = false;
                    }
                }
            }

            Item {
                id: visualContainer
                anchors.fill: parent
                opacity: edgeWindow.isActive ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutSine
                    }
                }

                // Top Edge Glow
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 100
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(edgeWindow.currentColor.r, edgeWindow.currentColor.g, edgeWindow.currentColor.b, theme.edgeLightingIntensity) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Bottom Edge Glow
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 100
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(edgeWindow.currentColor.r, edgeWindow.currentColor.g, edgeWindow.currentColor.b, theme.edgeLightingIntensity) }
                    }
                }

                // Left Edge Glow
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 100
                    color: "transparent"
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(edgeWindow.currentColor.r, edgeWindow.currentColor.g, edgeWindow.currentColor.b, theme.edgeLightingIntensity) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Right Edge Glow
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 100
                    color: "transparent"
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(edgeWindow.currentColor.r, edgeWindow.currentColor.g, edgeWindow.currentColor.b, theme.edgeLightingIntensity) }
                    }
                }

                // Inner sharp focus border lines (4px)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 4
                    color: edgeWindow.currentColor
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 4
                    color: edgeWindow.currentColor
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: edgeWindow.currentColor
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: edgeWindow.currentColor
                }

                // Segmented Edge Starfields (avoiding OpacityMask shader compiler issues)
                // Top Starfield
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 150
                    clip: true
                    Components.Starfield {
                        anchors.fill: parent
                        starCount: 40
                        starColor: theme.textMain
                    }
                }
                // Bottom Starfield
                Item {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 150
                    clip: true
                    Components.Starfield {
                        anchors.fill: parent
                        starCount: 40
                        starColor: theme.textMain
                    }
                }
                // Left Starfield
                Item {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 150
                    clip: true
                    Components.Starfield {
                        anchors.fill: parent
                        starCount: 40
                        starColor: theme.textMain
                    }
                }
                // Right Starfield
                Item {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 150
                    clip: true
                    Components.Starfield {
                        anchors.fill: parent
                        starCount: 40
                        starColor: theme.textMain
                    }
                }
            }
        }
    }
}
