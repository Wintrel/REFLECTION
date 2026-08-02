import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system"
import "../../../../core/state" as State
import "./account" as AccountCards

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true
    property int currentTab: 0 // 0: Profile, 1: Security, 2: System & Data

    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Tab Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Repeater {
                model: ["Profile", "Security", "System & Data"]
                
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 8
                    
                    property bool isSelected: root.currentTab === index
                    
                    color: isSelected ? (root.theme ? root.theme.accentPrimary : "#8C8C9E") : Qt.rgba(255, 255, 255, 0.05)
                    border.width: isSelected ? 0 : (maTab.containsMouse ? 1 : 0)
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                    
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
                
                // --- Tab 0: Profile ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 32
                    visible: root.currentTab === 0
                    
                    AccountCards.ProfileCard { theme: root.theme }
                    AccountCards.DisplayNameCard { theme: root.theme }
                }
                
                // --- Tab 1: Security ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 32
                    visible: root.currentTab === 1
                    
                    AccountCards.PasswordCard { theme: root.theme }
                    AccountCards.SshKeysCard { theme: root.theme }
                    AccountCards.ActiveSessionsCard { theme: root.theme }
                }
                
                // --- Tab 2: System & Data ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 32
                    visible: root.currentTab === 2
                    
                    AccountCards.StorageQuotaCard { theme: root.theme }
                    AccountCards.GroupMembershipCard { theme: root.theme }
                    AccountCards.ShellSelectorCard { theme: root.theme }
                }
                
                Item { Layout.preferredHeight: 40 } // Bottom padding
            }
        }
    }

    ProfilePictureCropper {
        id: avatarCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }

    BannerPictureCropper {
        id: bannerCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }
}
