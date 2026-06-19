import QtQuick

Item {
    id: root
    
    property real radiusIsland: 12
    property color bgBezel: "#000000"
    
    property var islandShape: null
    
    // Left Fillet (Concave swoop connecting to screen)
    Item {
        width: root.radiusIsland
        height: root.radiusIsland
        x: root.islandShape ? root.islandShape.x - width : -width
        y: 0
        clip: true
        
        Rectangle {
            width: 4 * root.radiusIsland
            height: 4 * root.radiusIsland
            radius: 2 * root.radiusIsland
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusIsland
            x: -2 * root.radiusIsland
            y: -root.radiusIsland
        }
    }
    
    // Right Fillet (Concave swoop connecting to screen)
    Item {
        width: root.radiusIsland
        height: root.radiusIsland
        x: root.islandShape ? root.islandShape.x + root.islandShape.width : 0
        y: 0
        clip: true
        
        Rectangle {
            width: 4 * root.radiusIsland
            height: 4 * root.radiusIsland
            radius: 2 * root.radiusIsland
            color: "transparent"
            border.color: root.bgBezel
            border.width: root.radiusIsland
            x: -root.radiusIsland
            y: -root.radiusIsland
        }
    }
}
