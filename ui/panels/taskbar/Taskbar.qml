import QtQuick
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

import "../../../core"
import "../../../core/services/system"
import "components"

PanelWindow {
    id: taskbarWindow

    anchors {
        bottom: true
        left: true
        right: true
    }

    // Make sure the window acts as an overlay and doesn't take up literal screen space
    exclusiveZone: 0
    color: "transparent"

    // Height needs to fit the visible taskbar plus a generous shadow region
    implicitHeight: theme.taskbarHeight + 30

    mask: Region {
        item: taskbarWrapper
    }

    property var theme: Theme { id: theme }

    Item {
        id: taskbarWrapper
        width: taskbarContainer.width + (2 * theme.taskbarRadius)
        height: taskbarContainer.height - theme.taskbarRadius
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        property bool isHidden: !HyprlandService.isWorkspaceEmpty && !taskbarHover.hovered

        anchors.bottomMargin: isHidden ? -(height - 2) : 0
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }

        HoverHandler { id: taskbarHover }

            Rectangle {
                id: taskbarContainer

                width: taskbarWindow.width * theme.taskbarWidthPercent
                height: theme.taskbarHeight + theme.taskbarRadius

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -theme.taskbarRadius

                radius: theme.taskbarRadius
                color: theme.bgBezel

                // Inner inset area
                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: theme.taskbarBorderWidth
                    anchors.rightMargin: theme.taskbarBorderWidth
                    anchors.topMargin: theme.taskbarBorderWidth
                    anchors.bottomMargin: theme.taskbarRadius + theme.taskbarBorderWidth

                    radius: parent.radius - 2
                    color: theme.bgInner
                }

                // Layout
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.bottomMargin: theme.taskbarRadius // Push bottom up so vertical center is correct

                    // Left: Workspaces
                    WorkspaceDots {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        theme: taskbarWindow.theme
                    }

                    // Center: Apps
                    AppNav {
                        anchors.centerIn: parent
                        theme: taskbarWindow.theme
                    }

                    // Right: Clock
                    Clock {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        theme: taskbarWindow.theme
                    }
                }
            }

            TaskbarFillets {
                taskbarShape: taskbarContainer
                radiusTaskbar: theme.taskbarRadius
                bgBezel: theme.bgBezel
            }
        }
    }
