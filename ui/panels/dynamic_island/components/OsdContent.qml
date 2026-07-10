import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system" as System

Item {
    id: root
    
    property int islandState: 0
    property int osdMode: 0
    property int osdPriority: 1
    property string osdIcon: ""
    property string osdText: ""
    property string osdColor: ""
    property var theme: null
    property real islandHoverW: 230
    property real islandHoverH: 50
    
    width: islandHoverW - 16
    height: islandHoverH - 16
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 8
    
    opacity: root.islandState === 5 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration : 250 } }
    
    // Bar Layout (Mode 0 & 1)
    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 16
        spacing: 12
        visible: root.osdMode !== 2
        
        // Icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (root.osdMode === 1) {
                    if (System.BrightnessService.brightness > 0.7) return "light_mode";
                    return "brightness_low";
                } else {
                    if (System.VolumeService.isMuted) return "volume_off";
                    if (System.VolumeService.volume > 0.6) return "volume_up";
                    if (System.VolumeService.volume > 0.3) return "volume_down";
                    return "volume_mute";
                }
            }
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 20
            color: root.theme ? root.theme.textMain : "#FFF"
        }
        
        // Progress Bar
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32 - 12
            height: 12
            radius: 6
            color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.2) : "#30A6ADC8"
            
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                width: parent.width * (root.osdMode === 1 ? System.BrightnessService.brightness : System.VolumeService.volume)
                color: root.theme ? root.theme.textMain : "#FFF"
                
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }
    }
    
    // Text Layout (Mode 2)
    Row {
        anchors.centerIn: parent
        spacing: 8
        visible: root.osdMode === 2
        
        Text {
            id: alertIcon
            anchors.verticalCenter: parent.verticalCenter
            text: root.osdIcon
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 20
            color: root.osdColor !== "" ? root.osdColor : (root.theme ? root.theme.textMain : "#FFF")
            
            transformOrigin: Item.Center
            
            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: root.islandState === 5 && root.osdMode === 2 && root.osdPriority >= 2
                
                NumberAnimation { from: 1.0; to: 1.25; duration: 300; easing.type: Easing.OutBack }
                NumberAnimation { from: 1.25; to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                PauseAnimation { duration: 800 }
            }
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.osdText
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            font.bold: root.osdPriority >= 2
            color: root.osdColor !== "" ? root.osdColor : (root.theme ? root.theme.textMain : "#FFF")
        }
    }
}
