import QtQuick

Item {
    id: root
    
    property real radiusTaskbar: 16
    property color bgBezel: "#000000"
    
    property var taskbarShape: null
    
    anchors.fill: parent
    
    // Left Fillet (Concave swoop connecting to screen bottom)
    Item {
        width: root.radiusTaskbar
        height: root.radiusTaskbar
        x: root.taskbarShape ? root.taskbarShape.x - width : -width
        y: parent.height - height
        clip: true
        
        Rectangle {
            width: 4 * root.radiusTaskbar
            height: 4 * root.radiusTaskbar
            radius: 2 * root.radiusTaskbar
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusTaskbar
            x: -2 * root.radiusTaskbar
            y: -2 * root.radiusTaskbar
        }
    }
    
    // Right Fillet (Concave swoop connecting to screen bottom)
    Item {
        width: root.radiusTaskbar
        height: root.radiusTaskbar
        x: root.taskbarShape ? root.taskbarShape.x + root.taskbarShape.width : 0
        y: parent.height - height
        clip: true
        
        Rectangle {
            width: 4 * root.radiusTaskbar
            height: 4 * root.radiusTaskbar
            radius: 2 * root.radiusTaskbar
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusTaskbar
            x: -root.radiusTaskbar
            y: -2 * root.radiusTaskbar
        }
    }
}
