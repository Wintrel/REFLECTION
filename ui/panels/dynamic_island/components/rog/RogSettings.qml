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

    property int currentTab: 0 // 0: Performance, 1: Power, 2: Lighting

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Tab Bar — matches PersonalizationSettings pattern
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: ["Performance", "Power", "Lighting"]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 8

                    property bool isSelected: root.currentTab === index

                    color: isSelected
                        ? (root.theme ? root.theme.accentPrimary : "#8C8C9E")
                        : (maTab.containsMouse ? Qt.rgba(255, 255, 255, 0.07) : Qt.rgba(255, 255, 255, 0.05))
                    border.width: isSelected ? 0 : (maTab.containsMouse ? 1 : 0)
                    border.color: Qt.rgba(255, 255, 255, 0.2)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: isSelected ? Font.Bold : Font.Normal
                        color: isSelected ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                    }

                    MouseArea {
                        id: maTab
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = index
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(255, 255, 255, 0.1)
        }

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

                // --- Tab 0: Performance ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 0

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

                // --- Tab 1: Power ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 1

                    Text {
                        text: "Battery Care"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    BatteryCareCard { theme: root.theme }
                }

                // --- Tab 2: Lighting ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 2

                    Text {
                        text: "Aura Sync"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentPrimary : "#FFF"
                    }

                    AuraCard { theme: root.theme }
                }

                Item { Layout.preferredHeight: 40 } // Bottom padding
            }
        }
    }
}
