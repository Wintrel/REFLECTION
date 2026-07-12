import QtQuick
import "../../../../core" as Core
import "../../../../core/services/system"

Item {
    id: root
    Component.onCompleted: console.log("ActionProgressContent loaded, inProgress:", ActionProgressService.inProgress, "text:", ActionProgressService.statusText)
    
    property int islandState: 0
    property var theme: null
    
    width: theme ? theme.islandNotifW : 300
    height: theme ? theme.islandNotifH : 100
    
    opacity: islandState === 7 ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    
    // Main Content
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -4
        spacing: 16
        
        property bool isVisible: root.islandState === 7
        opacity: isVisible ? 1 : 0
        transform: Translate {
            y: isVisible ? 0 : -5
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        
        // Text
        Text {
            text: ActionProgressService.statusText
            font.family: theme ? theme.fontMain : "Inter"
            font.pixelSize: 15
            color: theme ? theme.textMain : "#FFF"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // The Indeterminate Progress Bar
    Item {
        width: parent.width - 64
        height: 6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        
        property bool isVisible: root.islandState === 7
        opacity: isVisible ? 1 : 0
        transform: Translate {
            y: isVisible ? 0 : 5
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        clip: true
        
        // Track
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(255,255,255,0.1)
            radius: parent.height / 2
        }
        
        // Indeterminate loader (only visible when inProgress)
        Rectangle {
            id: progressShimmer
            height: parent.height
            width: 100
            x: -width
            radius: parent.height / 2
            
            visible: ActionProgressService.inProgress
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { 
                    position: 0.5; 
                    color: theme ? Qt.rgba(theme.colorSystemShimmer.r, theme.colorSystemShimmer.g, theme.colorSystemShimmer.b, 1.0) : Qt.rgba(0, 1, 1, 1.0) 
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
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        // Resolved line (fills exactly when success/fail)
        Rectangle {
            anchors.fill: parent
            radius: parent.height / 2
            color: ActionProgressService.isSuccess ? (theme ? theme.accentWorkspace : "#5611f8") : "#f8113b"
            
            opacity: ActionProgressService.isResolving ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
    }
}
