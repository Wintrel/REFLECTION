import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property real radiusIsland: 12
    property color bgBezel: "#000000"
    
    property var islandShape: null
    
    property bool isActive: false
    property color glowColor: "transparent"
    property color shimmerColor: "transparent"
    property int borderWidth: 0
    property int drawnBorderWidth: borderWidth > 0 ? 1 : 0
    property int animDuration: 400
    
    // Left Fillet (Concave swoop connecting island to top screen bezel)
    Item {
        width: root.radiusIsland
        height: root.radiusIsland
        x: root.islandShape ? root.islandShape.x - width + root.drawnBorderWidth : -width
        y: 0
        clip: true
        
        // Solid black bezel concave fill
        Rectangle {
            id: leftFilletShape
            width: 4 * root.radiusIsland
            height: 4 * root.radiusIsland
            radius: 2 * root.radiusIsland
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusIsland
            x: -2 * root.radiusIsland
            y: -root.radiusIsland
        }
        
        // 1px Shimmer / Glass Border Curve
        Rectangle {
            width: 2 * root.radiusIsland
            height: 2 * root.radiusIsland
            radius: root.radiusIsland
            color: "transparent"
            border.color: root.isActive ? root.shimmerColor : "transparent"
            border.width: root.drawnBorderWidth
            x: -root.radiusIsland
            y: 0
            
            Behavior on border.color { ColorAnimation { duration: root.animDuration; easing.type: Easing.OutSine } }
        }
    }
    
    // Right Fillet (Concave swoop connecting island to top screen bezel)
    Item {
        width: root.radiusIsland
        height: root.radiusIsland
        x: root.islandShape ? root.islandShape.x + root.islandShape.width - root.drawnBorderWidth : 0
        y: 0
        clip: true
        
        // Solid black bezel concave fill
        Rectangle {
            id: rightFilletShape
            width: 4 * root.radiusIsland
            height: 4 * root.radiusIsland
            radius: 2 * root.radiusIsland
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusIsland
            x: -root.radiusIsland
            y: -root.radiusIsland
        }
        
        // 1px Shimmer / Glass Border Curve
        Rectangle {
            width: 2 * root.radiusIsland
            height: 2 * root.radiusIsland
            radius: root.radiusIsland
            color: "transparent"
            border.color: root.isActive ? root.shimmerColor : "transparent"
            border.width: root.drawnBorderWidth
            x: 0
            y: 0
            
            Behavior on border.color { ColorAnimation { duration: root.animDuration; easing.type: Easing.OutSine } }
        }
    }
}
