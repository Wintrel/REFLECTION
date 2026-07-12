import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    Component.onCompleted: console.log("ActionProgressContent loaded, inProgress:", ActionProgressService.inProgress, "text:", ActionProgressService.statusText)
    
    property int islandState: 0
    property var theme: null
    
    property real islandMaxW: 600
    property real islandMaxH: 200
    
    // We bind root width/height to the passed bounds to avoid constraints
    width: islandMaxW
    height: islandMaxH
    
    property bool isActive: islandState === 7
    opacity: isActive ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }

    // Dynamic Starfield Background (Match PromptContent exactly for seamless transition)
    Components.Starfield {
        anchors.fill: parent
        starCount: 30
        starColor: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff5555" : (theme ? theme.accentPrimary : "#00ffcc")
        opacity: isActive ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }
    
    // Main Content (Centered 600x200 canvas layout)
    Item {
        width: islandMaxW
        height: islandMaxH
        anchors.centerIn: parent

        // 1. The Crown (Top-Center)
        Item {
            id: iconContainer
            width: 48
            height: 48
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            
            Rectangle {
                anchors.fill: parent
                radius: 24
                color: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? Qt.rgba(1, 0, 0, 0.15) : (theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0,1,0.8,0.15))
            }

            Text {
                text: {
                    if (ActionProgressService.isResolving) {
                        return ActionProgressService.isSuccess ? "check_circle" : "error"
                    }
                    return "hourglass_top"
                }
                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff4444" : (theme ? theme.accentPrimary : "#00ffcc")
                anchors.centerIn: parent
                
                // Spin animation for loading state
                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 2000
                    running: root.isActive && !ActionProgressService.isResolving
                }
            }
        }
        
        // 2. The Context (Middle-Center)
        Column {
            anchors.top: iconContainer.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Text {
                text: ActionProgressService.isResolving ? (ActionProgressService.isSuccess ? "Success" : "Failed") : "Action in Progress"
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff4444" : Qt.rgba(255, 255, 255, 0.6)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: ActionProgressService.statusText
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: ActionProgressService.isResolving && !ActionProgressService.isSuccess ? "#ff5555" : (theme ? theme.textMain : "#FFF")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        
        // 3. The Input Horizon / Progress Bar (Bottom-Center)
        Item {
            id: progressContainer
            width: 400
            height: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 // Tweak to vertically center it roughly where the text input was
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Track
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0,0,0,0.5) // Deep void inset matching text field
                radius: 6
                border.width: 1
                border.color: Qt.rgba(255,255,255,0.1)
                
                layer.enabled: true
                layer.effect: InnerShadow {
                    color: Qt.rgba(0,0,0,0.8)
                    radius: 4
                    spread: 0.3
                }
            }
            
            // Indeterminate loader (only visible when inProgress)
            Rectangle {
                id: progressShimmer
                height: parent.height - 2
                width: 150
                y: 1
                x: -width
                radius: height / 2
                
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
                        to: progressShimmer.parent.width
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }
                }
            }
            
            // Resolved line (fills exactly when success/fail)
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: height / 2
                color: ActionProgressService.isSuccess ? (theme ? theme.accentPrimary : "#00ffcc") : "#ff4444"
                
                opacity: ActionProgressService.isResolving ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }
        }
    }
}
