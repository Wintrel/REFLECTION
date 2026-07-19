import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: colLayout.implicitHeight
        clip: true

        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.DragAndOvershootBounds

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: colLayout
            width: parent.width
            spacing: 32

            // Profile Header Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 280
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.02)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    // Avatar with glow
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 100
                        height: 100
                        transformOrigin: Item.Center

                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent
                            radius: 50
                            visible: false
                        }

                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            source: "../../../../../assets/WintrelPFP.png"
                            sourceSize.width: 200
                            sourceSize.height: 200
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                        }

                        OpacityMask {
                            id: maskedAvatar
                            anchors.fill: parent
                            source: avatarImage
                            maskSource: avatarMask
                        }
                        
                        DropShadow {
                            anchors.fill: maskedAvatar
                            source: maskedAvatar
                            transparentBorder: true
                            color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                            radius: avatarMa.containsMouse ? 30 : 20
                            samples: 35
                            opacity: avatarMa.containsMouse ? 0.7 : 0.4
                            z: -1
                            Behavior on radius { NumberAnimation { duration: 300 } }
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                        
                        MouseArea {
                            id: avatarMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                parent.rotation = 0
                                avatarRotAnim.restart()
                            }
                        }
                        
                        NumberAnimation on rotation {
                            id: avatarRotAnim
                            from: 0
                            to: 360
                            duration: 600
                            easing.type: Easing.OutBack
                            running: false
                        }
                    }

                    // Name
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Wintrel"
                        font.family: "Inter"
                        font.pixelSize: 28
                        font.weight: Font.Black
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }

                    // Bio
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Building interfaces. Breaking shells."
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.italic: true
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }
            
            // RPG Stats Grid
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: statsLayout.implicitHeight + 32
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.02)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)
                
                GridLayout {
                    id: statsLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 20
                    
                    Repeater {
                        model: [
                            { icon: "bug_report", title: "Bugs Created", value: "Countless" },
                            { icon: "coffee", title: "Coffee Consumed", value: "9,001 Cups" },
                            { icon: "keyboard", title: "Lines of Code", value: "Too Many" },
                            { icon: "favorite", title: "Passion for UI", value: "100%" }
                        ]
                        
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: Qt.rgba(255, 255, 255, 0.04)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.1)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: modelData.title
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                                Text {
                                    text: modelData.value
                                    font.family: "Inter"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }
                            }
                        }
                    }
                }
            }

            // Do not click button
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.02)
                border.width: 1
                border.color: nopeMa.containsMouse ? Qt.rgba(255, 100, 100, 0.3) : Qt.rgba(255, 255, 255, 0.05)
                Behavior on border.color { ColorAnimation { duration: 200 } }
                
                property int nopeCount: 0
                
                MouseArea {
                    id: nopeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: parent.nopeCount++
                }
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "warning"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: nopeMa.containsMouse ? "#FF6B6B" : (root.theme ? root.theme.textSub : "#888")
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Text {
                        text: parent.parent.nopeCount === 0 ? "Do not click" : "Clicks: " + parent.parent.nopeCount
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: nopeMa.containsMouse ? "#FF6B6B" : (root.theme ? root.theme.textMain : "#FFF")
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }
            
            Item { Layout.preferredHeight: 40 }
        }
    }
}
