import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 12

    Text {
        text: "Select a performance profile. Turbo mode may increase fan noise."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }

    // Card container — matches AudioLabCard style
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: selectorRow.implicitHeight + 24
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.05)

        RowLayout {
            id: selectorRow
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 8

            Repeater {
                model: [
                    { name: "Quiet",    icon: "eco",           desc: "Silent & cool"    },
                    { name: "Balanced", icon: "balance",        desc: "Best of both"     },
                    { name: "Turbo",    icon: "rocket_launch",  desc: "Max performance"  }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    radius: 10

                    property bool isCurrent: index === RogService.performanceProfile

                    // Translucent tint when active instead of solid fill
                    color: isCurrent
                        ? Qt.rgba(
                            root.theme ? root.theme.accentPrimary.r : 1,
                            root.theme ? root.theme.accentPrimary.g : 0.7,
                            root.theme ? root.theme.accentPrimary.b : 0,
                            0.15)
                        : (maBtn.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")

                    border.width: 1
                    border.color: isCurrent
                        ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                        : (maBtn.containsMouse ? Qt.rgba(255, 255, 255, 0.12) : Qt.rgba(255, 255, 255, 0.06))

                    Behavior on color       { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    scale: maBtn.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 22
                            color: isCurrent
                                ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                                : (root.theme ? root.theme.textMain : "#FFF")
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            font.weight: isCurrent ? Font.DemiBold : Font.Normal
                            color: isCurrent
                                ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                                : (root.theme ? root.theme.textMain : "#FFF")
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.desc
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: root.theme ? root.theme.textSub : "#888"
                            opacity: isCurrent ? 1.0 : 0.6
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: maBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: RogService.setPerformanceProfile(index)
                    }
                }
            }
        }
    }
}
