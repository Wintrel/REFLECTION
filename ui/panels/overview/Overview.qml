import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../../core" as Core
import "../../../core/monitors"
import "../../../core/state" as State

Scope {
    id: overviewScope

    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: overviewWindow
            Core.Theme { id: theme }

            required property var modelData
            screen: modelData

            visible: State.GlobalStates.overviewOpen
            color: "transparent"

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: State.GlobalStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0

            // Only mask the widget area so clicks outside close the overview
            mask: Region {
                item: State.GlobalStates.overviewOpen ? overviewWidget : null
            }

            // No dark background - completely transparent overlay

            // Click outside to close
            MouseArea {
                anchors.fill: parent
                visible: State.GlobalStates.overviewOpen
                focus: State.GlobalStates.overviewOpen
                onClicked: {
                    State.GlobalStates.overviewOpen = false;
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        State.GlobalStates.overviewOpen = false;
                        event.accepted = true;
                    }
                }
            }

            OverviewWidget {
                id: overviewWidget
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: State.GlobalStates.currentIslandHeight + 20
                
                theme: theme
                overviewVisible: State.GlobalStates.overviewOpen
                targetMonitorName: modelData.name
            }
        }
    }
}
