import QtQuick
import Quickshell

Item {
    id: root
    
    property var theme
    property string icon: ""
    property real value: 0 // 0 to 100
    signal valueChangedByUser(real newValue)
    signal rightClicked()
    
    height: 48
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: height / 2
        color: root.theme ? Qt.rgba(255,255,255,0.05) : "#111"
        border.width: 1
        border.color: root.theme ? Qt.rgba(255,255,255,0.05) : "#222"
        clip: true
        
        // Fill
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (root.value / 100)
            radius: parent.radius
            
            // Focus Color Philosophy: Orange when adjusting, neutral (white) when idle.
            color: ma.pressed ? (root.theme ? root.theme.accentPrimary : "#ff9900") : (root.theme ? root.theme.textMain : "#FFF")
            opacity: 0.9

            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            // 250ms fade back to neutral after release
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        
        // Icon
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 20
            color: root.value > 10 ? (root.theme ? root.theme.bgBase : "#000") : (root.theme ? root.theme.textMain : "#FFF")
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        // Value Text
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.value) + "%"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            font.bold: true
            color: root.value > 90 ? (root.theme ? root.theme.bgBase : "#000") : (root.theme ? root.theme.textMain : "#FFF")
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            function updateValue(mouse) {
                if (mouse.button === Qt.RightButton) return;
                var val = (mouse.x / width) * 100;
                val = Math.max(0, Math.min(100, val));
                root.valueChangedByUser(val);
            }
            
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.rightClicked();
                }
            }
            
            onPressed: mouse => updateValue(mouse)
            onPositionChanged: mouse => {
                if (pressed && mouse.buttons & Qt.LeftButton) updateValue(mouse);
            }
        }
    }
}
