import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8

    Text {
        text: "Credits"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: creditsLayout.implicitHeight + 32
        radius: 8
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.04)

        ColumnLayout {
            id: creditsLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 20

            // Built by
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Qt.rgba(255, 255, 255, 0.06)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.1)

                    Text {
                        anchors.centerIn: parent
                        text: "person"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Built by"
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                    Text {
                        text: "fuyumi"
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(255, 255, 255, 0.06)
            }

            // Powered by
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Powered by"
                    font.family: "Inter"
                    font.pixelSize: 11
                    color: root.theme ? root.theme.textSub : "#888"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: ["Quickshell", "Qt / QML", "Wayland"]

                        delegate: Rectangle {
                            width: badgeText.implicitWidth + 20
                            height: 28
                            radius: 14
                            color: Qt.rgba(255, 255, 255, 0.03)
                            border.width: 1
                            border.color: badgeMa.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(255, 255, 255, 0.08)
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            MouseArea {
                                id: badgeMa
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: modelData
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: badgeMa.containsMouse ? (root.theme ? root.theme.accentPrimary : "#4ADE80") : (root.theme ? root.theme.textMain : "#FFF")
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(255, 255, 255, 0.06)
            }

            // Special Thanks
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Special Thanks"
                    font.family: "Inter"
                    font.pixelSize: 11
                    color: root.theme ? root.theme.textSub : "#888"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "favorite"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                        opacity: 0.7
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "End-4 / Illogical Impulse"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }

                        Text {
                            text: "The spark that started Reflection"
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.italic: true
                            color: root.theme ? root.theme.textSub : "#888"
                            opacity: 0.8
                        }
                    }
                }
            }
        }
    }
}
