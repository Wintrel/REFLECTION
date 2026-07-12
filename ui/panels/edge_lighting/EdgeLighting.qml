import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../components" as Components
import "../../../core" as Core
import "../../../core/state" as State

Scope {
    Variants {
        model: Quickshell.screens

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
            
            Connections {
                target: State.GlobalStates
                function onNotificationTriggered() {
                    edgeWindow.isActive = true;
                    hideTimer.restart();
                }
            }

            Timer {
                id: hideTimer
                interval: 5000 // 5 seconds of edge glow
                onTriggered: {
                    edgeWindow.isActive = false;
                }
            }

            Item {
                id: visualContainer
                anchors.fill: parent
                opacity: edgeWindow.isActive ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutSine
                    }
                }

                // Deep Void Glow (Using two rectangles for an intense soft glow)
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 15
                    border.color: Qt.rgba(theme.colorNotification.r, theme.colorNotification.g, theme.colorNotification.b, 0.5)
                    
                    layer.enabled: true
                    layer.effect: GaussianBlur {
                        radius: 80
                        samples: 128
                        transparentBorder: true
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 4
                    border.color: theme.colorNotification
                    
                    layer.enabled: true
                    layer.effect: GaussianBlur {
                        radius: 20
                        samples: 32
                        transparentBorder: true
                    }
                }

                // Edge Starfield
                Item {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: visualContainer.width
                            height: visualContainer.height
                            color: "transparent"
                            border.color: "black"
                            border.width: 150 // The stars will only show within 150px of the edge
                        }
                    }
                    
                    Components.Starfield {
                        anchors.fill: parent
                        starCount: 150 // Dense starry edge
                        starColor: theme.textMain
                    }
                }
            }
        }
    }
}
