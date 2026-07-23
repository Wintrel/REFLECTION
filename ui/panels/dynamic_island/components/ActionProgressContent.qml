import "core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    Component.onCompleted: console.log("ActionProgressContent loaded, inProgress:", ActionProgressService.inProgress, "text:", ActionProgressService.statusText)
    
    property int islandState: State.IslandState.idle
    property var theme: null
    
    property real islandMaxW: 600
    property real islandMaxH: 200
    
    // We bind root width/height to the passed bounds to avoid constraints
    width: islandMaxW
    height: islandMaxH
    
    property bool isActive: islandState === State.IslandState.actionProgress
    opacity: isActive ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }

    // Dynamic Starfield Background (Match PromptContent exactly for seamless transition)
    Components.Starfield {
        anchors.fill: parent
        starCount: 20 // Slightly fewer stars for the smaller profile
        starColor: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff5555" : (theme ? theme.accentPrimary : "#00ffcc")
        opacity: isActive ? 0.35 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }
    
    // Main Content (Centered compact layout)
    Item {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        Row {
            anchors.fill: parent
            spacing: 16
            
            // 1. Icon Container (Delicate ring with smaller spinner)
            Item {
                id: iconContainer
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "transparent"
                    border.width: 1
                    border.color: {
                        if (ActionProgressService.isResolving) {
                            return ActionProgressService.isSuccess ? (theme ? theme.accentPrimary : "#00ffcc") : "#ff4444"
                        }
                        return theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.25) : Qt.rgba(0,1,0.8,0.25)
                    }
                    Behavior on border.color { ColorAnimation { duration: 300 } }
                }

                // Loading Spinner Icon (only shown when not resolving)
                Text {
                    anchors.centerIn: parent
                    visible: !ActionProgressService.isResolving
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                    
                    text: "hourglass_top"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    
                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 2000
                        running: root.isActive && !ActionProgressService.isResolving
                    }
                }

                // Status Icon (only shown when resolving - Success / Error)
                Text {
                    anchors.centerIn: parent
                    visible: ActionProgressService.isResolving
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                    
                    text: ActionProgressService.isSuccess ? "check_circle" : "error"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: ActionProgressService.isSuccess ? (theme ? theme.accentPrimary : "#00ffcc") : "#ff4444"
                    rotation: 0 // Keep it perfectly straight
                }
            }
            
            // 2. The Context & Progress Rail Column
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - iconContainer.width - parent.spacing
                spacing: 8
                
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        text: ActionProgressService.isResolving ? (ActionProgressService.isSuccess ? "Success" : "Failed") : "Action in Progress"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Light
                        color: {
                            if (ActionProgressService.isResolving) {
                                return ActionProgressService.isSuccess ? (theme ? theme.textMain : "#FFF") : "#ff4444"
                            }
                            return theme ? theme.textMain : "#FFF"
                        }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                    
                    Text {
                        text: "•  " + ActionProgressService.statusText
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 12
                        font.weight: Font.Light
                        color: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff5555" : Qt.rgba(255, 255, 255, 0.4)
                        elide: Text.ElideRight
                        width: parent.width - 150
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
                
                // 3. Thin 3px Progress Rail (with thoughtful glowing effect and horizontal clip)
                Item {
                    id: progressContainer
                    width: parent.width - 12
                    height: 16 // Increased height to allow vertical glow, combined with clip: true
                    clip: true
                    
                    // Track (centered vertically)
                    Rectangle {
                        id: progressTrack
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        color: Qt.rgba(255, 255, 255, 0.08)
                        radius: 1.5
                    }
                    
                    // Indeterminate loader (centered vertically)
                    Rectangle {
                        id: progressShimmer
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        width: 100
                        radius: 1.5
                        visible: ActionProgressService.inProgress
                        
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { 
                                position: 0.5; 
                                color: root.theme ? root.theme.accentPrimary : "#00ffcc" 
                            }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        
                        SequentialAnimation on x {
                            running: ActionProgressService.inProgress && root.visible
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: -progressShimmer.width
                                to: progressContainer.width
                                duration: 1400
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                    
                    // Thoughtful shimmer glow
                    RectangularGlow {
                        anchors.fill: progressShimmer
                        glowRadius: 3
                        spread: 0.05
                        color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.25) : Qt.rgba(0, 255, 204, 0.25)
                        cornerRadius: progressShimmer.radius + glowRadius
                        visible: progressShimmer.visible
                    }
                    
                    // Resolved line (fills exactly when success/fail, centered vertically)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        radius: 1.5
                        color: ActionProgressService.isSuccess ? (theme ? theme.accentPrimary : "#00ffcc") : "#ff4444"
                        opacity: ActionProgressService.isResolving ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                    
                    // Thoughtful resolved status glow
                    RectangularGlow {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        glowRadius: 3
                        spread: 0.05
                        color: ActionProgressService.isSuccess ? (theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.2) : Qt.rgba(0, 255, 204, 0.2)) : Qt.rgba(255, 68, 68, 0.2)
                        cornerRadius: 1.5 + glowRadius
                        opacity: ActionProgressService.isResolving ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                }
            }
        }
    }
}
