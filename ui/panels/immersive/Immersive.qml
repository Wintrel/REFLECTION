import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../../core" as Core
import "../../../core/monitors"
import "../../../core/state" as State

Scope {
    id: immersiveScope

    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: immersiveWindow
            Core.Theme { id: theme }

            required property var modelData
            screen: modelData

            property bool wantsVisible: State.GlobalStates.immersiveOpen
            visible: wantsVisible || closeTimer.running

            Timer {
                id: closeTimer
                interval: 300
            }

            onWantsVisibleChanged: {
                if (!wantsVisible) {
                    closeTimer.start();
                } else {
                    closeTimer.stop();
                }
            }

            color: "transparent"

            WlrLayershell.namespace: "quickshell:immersive"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: State.GlobalStates.immersiveOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0

            // Solid dark background for the immersive view
            Rectangle {
                anchors.fill: parent
                color: theme ? (theme.bgBase || "#0A0A0C") : "#0A0A0C"
                opacity: State.GlobalStates.immersiveOpen ? 0.95 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    // Do not close on click for settings by default, but we can capture clicks if needed
                    // Actually, let's allow Esc to close it
                    focus: State.GlobalStates.immersiveOpen
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            State.GlobalStates.closeImmersive();
                            event.accepted = true;
                        }
                    }
                }
            }

            ImmersiveSettings {
                id: immersiveSettings
                anchors.fill: parent
                theme: theme
                isActive: State.GlobalStates.immersiveOpen
            }
        }
    }
}
