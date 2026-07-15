import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 1. Unified Profile Card
            Rectangle {
    id: root
    property var theme

                Layout.fillWidth: true
                // implicitHeight = banner height + avatar margin + details height + top margin + bottom padding
                implicitHeight: 140 + 60 + detailsColumn.implicitHeight + 40
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.03)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)
                
                // Banner Area
                Item {
                    id: bannerArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: 140
                    
                    Item {
                        id: bannerMaskItem
                        anchors.fill: parent
                        Rectangle {
                            anchors.fill: parent
                            radius: 11
                            color: "black"
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 11
                            color: "black"
                        }
                    }
                    
                    ShaderEffectSource {
                        id: bannerMask
                        sourceItem: bannerMaskItem
                        hideSource: true
                    }
                    
                    Item {
                        id: bannerContent
                        anchors.fill: parent
                        
                        Image {
                            id: bannerImg
                            anchors.fill: parent
                            source: AccountService.bannerPicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: AccountService.bannerPicture !== ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "add_photo_alternate"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 32
                            color: root.theme ? root.theme.textSub : "#888"
                            visible: AccountService.bannerPicture === ""
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: maBanner.containsMouse ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Change Banner"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: "#FFF"
                            }
                        }
                    }
                    
                    ShaderEffectSource {
                        id: bannerSource
                        sourceItem: bannerContent
                        hideSource: true
                    }
                    
                    OpacityMask {
                        anchors.fill: parent
                        source: bannerSource
                        maskSource: bannerMask
                    }
                    
                    MouseArea {
                        id: maBanner
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            State.GlobalStates.openFilePicker("Select Banner Picture", "images", function(file) {
                                bannerCropper.imageSource = "file://" + file;
                            });
                        }
                    }
                }
                
                // Divider line connecting banner to card body
                Rectangle {
                    anchors.top: bannerArea.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.05)
                }

                // Avatar Container
                Rectangle {
                    id: avatarContainer
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.top: bannerArea.bottom
                    anchors.topMargin: -40
                    width: 100
                    height: 100
                    radius: 50
                    color: root.theme ? root.theme.bgBase : "#111" // Match shell background to look like a cutout
                    border.width: 4
                    border.color: root.theme ? root.theme.bgBase : "#111"
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Qt.rgba(255, 255, 255, 0.05)
                        clip: true
                        
                        Image {
                            id: avatarImg
                            anchors.fill: parent
                            source: AccountService.profilePicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }
                        
                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent
                            radius: width / 2
                            visible: false
                        }
                        
                        OpacityMask {
                            anchors.fill: parent
                            source: avatarImg
                            maskSource: avatarMask
                            visible: avatarImg.source.toString() !== ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "person"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 32
                            color: root.theme ? root.theme.textMain : "#FFF"
                            visible: avatarImg.source.toString() === ""
                        }
                        
                        // Avatar Hover Overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: maAvatar.containsMouse ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "edit"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 24
                                color: "#FFF"
                            }
                        }
                        
                        MouseArea {
                            id: maAvatar
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                State.GlobalStates.openFilePicker("Select Profile Picture", "images", function(file) {
                                    avatarCropper.imageSource = "file://" + file;
                                });
                            }
                        }
                    }
                }
                
                // System Info (Details)
                ColumnLayout {
                    id: detailsColumn
                    anchors.top: avatarContainer.bottom
                    anchors.topMargin: 24
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 24
                    spacing: 10
                    
                    // Helper layout for each details row (Username, Display Name, Home Dir, Groups)
                    Rectangle {
                        id: userCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maUserRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maUserRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maUserRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: userIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "badge"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: userIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Username"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.username
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: realNameCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maRealNameRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maRealNameRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maRealNameRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: realNameIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "face"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: realNameIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Display Name"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.realName
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: homeCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maHomeRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maHomeRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maHomeRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: homeIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "folder"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: homeIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Home Directory"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.homeDir
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                elide: Text.ElideMiddle
                            }
                        }
                    }

                    Rectangle {
                        id: uidCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maUidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maUidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maUidRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: uidIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "fingerprint"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: uidIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "User ID (UID)"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.uid
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: gidCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maGidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maGidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maGidRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: gidIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "badge"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: gidIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Primary Group ID (GID)"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.gid
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: groupsCard
                        Layout.fillWidth: true
                        implicitHeight: Math.max(52, groupsColumn.implicitHeight + 16)
                        radius: 8
                        color: maGroupsRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maGroupsRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maGroupsRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: groupsIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "group"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            id: groupsColumn
                            anchors.left: groupsIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "User Groups"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.groups
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
