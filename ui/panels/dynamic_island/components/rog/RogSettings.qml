import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Content Area
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true

            flickDeceleration: 1000
            maximumFlickVelocity: 4000
            boundsBehavior: Flickable.DragAndOvershootBounds

            Behavior on contentY {
                enabled: !dragging && !flicking
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 24

                // --- Performance ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Performance Mode"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    PerformanceCard { theme: root.theme }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(255, 255, 255, 0.07)
                    }

                    Text {
                        text: "GPU Mode (MUX Switch)"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    GpuModeCard { theme: root.theme }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.07)
                }

                // --- Power ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Battery Care"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    BatteryCareCard { theme: root.theme }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.07)
                }

                // --- Lighting ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Aura Sync"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    AuraCard { theme: root.theme }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.07)
                }

                // --- Macros ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Macros"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    MacroCard { theme: root.theme }
                }

                Item { Layout.preferredHeight: 40 } // Bottom padding
            }
        }
    }
}
