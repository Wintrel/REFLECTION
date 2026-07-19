import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8

    Text {
        text: "Reflection Features"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: featuresList.implicitHeight + 24
        radius: 8
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.04)

        ColumnLayout {
            id: featuresList
            anchors.fill: parent
            anchors.margins: 12
            spacing: 0

            Repeater {
                model: ListModel {
                    ListElement { icon: "blur_on"; name: "Dynamic Island"; desc: "Fluid multi-state ambient controller" }
                    ListElement { icon: "auto_awesome"; name: "Ambient Idle"; desc: "OLED-safe starfield animations" }
                    ListElement { icon: "palette"; name: "Theming"; desc: "Accent-reactive color system" }
                    ListElement { icon: "notifications_active"; name: "Notifications"; desc: "Contextual priority engine" }
                    ListElement { icon: "screenshot_monitor"; name: "Screenshots"; desc: "Native screencopy pipeline" }
                    ListElement { icon: "music_note"; name: "Music Visualizer"; desc: "CAVA-powered aurora beams" }
                    ListElement { icon: "lock"; name: "Lockscreen"; desc: "PAM-integrated security" }
                }

                delegate: Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 6
                    color: featureMa.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    MouseArea {
                        id: featureMa
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 12

                        Text {
                            text: model.icon
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: featureMa.containsMouse
                                ? (root.theme ? root.theme.accentPrimary : "#4ADE80")
                                : (root.theme ? root.theme.textSub : "#888")
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: model.name
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: root.theme ? root.theme.textMain : "#FFF"
                            }

                            Text {
                                text: model.desc
                                font.family: "Inter"
                                font.pixelSize: 11
                                color: root.theme ? root.theme.textSub : "#888"
                            }
                        }
                    }
                }
            }
        }
    }
}
