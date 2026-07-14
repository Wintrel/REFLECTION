import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"

Item {
    id: root
    anchors.fill: parent
    
    property var theme
    property int islandState
    
    // Only show when in state 11
    property bool isActive: islandState === 11
    opacity: isActive ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    
    // State to track selected category
    property int currentCategory: 0
    property var categories: ["Account", "Personalization", "Behavior", "Shell", "About"]
    
    // Consume clicks on the actual UI so they don't fall through and close the settings,
    // but leave the 20px margins (the "tippy top" and edges) open to be clicked to close!
    MouseArea {
        anchors.fill: mainLayout
        onClicked: {}
    }
    
    RowLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Left Sidebar (Navigation)..
        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.maximumWidth: 220
            Layout.fillHeight: true
            spacing: 24
            
            // Profile Section
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    radius: 24
                    color: Qt.rgba(255, 255, 255, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: AccountService.profilePicture
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: source.toString() !== ""
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "person"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: root.theme ? root.theme.textMain : "#FFF"
                        visible: parent.children[0].source.toString() === ""
                    }
                }
                
                Column {
                    Layout.fillWidth: true
                    
                    Text {
                        width: parent.width
                        text: AccountService.realName || AccountService.username || Quickshell.env("USER")
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.textMain : "#FFF"
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: "Local Account"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                        elide: Text.ElideRight
                    }
                }
            }
            
            // Navigation List
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.categories
                spacing: 8
                interactive: false
                
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    radius: 8
                    
                    property bool isSelected: root.currentCategory === index
                    
                    color: isSelected ? (root.theme ? root.theme.accentPrimary : "#444") : (maCategory.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        spacing: 12
                        
                        Text {
                            text: {
                                if (modelData === "Account") return "manage_accounts";
                                if (modelData === "Personalization") return "palette";
                                if (modelData === "Behavior") return "psychology";
                                if (modelData === "Shell") return "desktop_windows";
                                return "info";
                            }
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: isSelected ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: modelData
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            font.weight: isSelected ? Font.DemiBold : Font.Normal
                            color: isSelected ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    MouseArea {
                        id: maCategory
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentCategory = index
                    }
                }
            }
        }
        
        // Vertical Divider
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: Qt.rgba(255, 255, 255, 0.1)
        }
        
        // Right Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Content Header
            Text {
                id: contentHeader
                text: root.categories[root.currentCategory]
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 10
            }
            
            // Main Content Area
            StackLayout {
                anchors.top: contentHeader.bottom
                anchors.topMargin: 24
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                currentIndex: root.currentCategory
                
                // 0: Account
                AccountSettings {
                    theme: root.theme
                }
                
                // 1: Personalization
                Rectangle {
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                    Text { anchors.centerIn: parent; text: "Personalization Settings"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter" }
                }
                
                // 2: Behavior
                Rectangle {
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                    Text { anchors.centerIn: parent; text: "Behavior Settings"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter" }
                }
                
                // 3: Shell
                Rectangle {
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                    Text { anchors.centerIn: parent; text: "Shell Settings"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter" }
                }
                
                // 4: About
                Rectangle {
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                    Text { anchors.centerIn: parent; text: "About Reflection"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter" }
                }
            }
        }
    }
}
