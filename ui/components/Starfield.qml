import QtQuick

Item {
    id: root
    
    // Amount of stars in the void
    property int starCount: 40
    
    // Base color of the stars
    property color starColor: "#ffffff"
    
    clip: true
    
    Repeater {
        model: root.starCount
        
        Item {
            id: starWrapper
            
            // Randomize position across the entire parent item
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            // Randomize size between 1.0 and 2.5 pixels
            property real size: 1.0 + Math.random() * 1.5
            width: size
            height: size
            
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.starColor
                
                // Base opacity is nearly invisible
                opacity: 0.05
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.visible
                    
                    // Random pause at the start so all stars don't shimmer in sync
                    PauseAnimation { duration: Math.random() * 6000 }
                    
                    // Smoothly fade in
                    NumberAnimation { 
                        from: 0.05 
                        to: 0.2 + Math.random() * 0.4 
                        duration: 4000 + Math.random() * 4000
                        easing.type: Easing.InOutSine 
                    }
                    
                    // Smoothly fade out
                    NumberAnimation { 
                        from: 0.2 + Math.random() * 0.4 
                        to: 0.05 
                        duration: 4000 + Math.random() * 4000
                        easing.type: Easing.InOutSine 
                    }
                    
                    // Random pause before shimmering again
                    PauseAnimation { duration: 1000 + Math.random() * 3000 }
                }
            }
            
            // Extremely slow, subtle vertical drift to make the void feel 3D and alive
            SequentialAnimation on y {
                loops: Animation.Infinite
                running: root.visible
                
                PauseAnimation { duration: Math.random() * 4000 }
                
                NumberAnimation { 
                    from: starWrapper.y
                    to: starWrapper.y - (3 + Math.random() * 8)
                    duration: 15000 + Math.random() * 10000
                    easing.type: Easing.InOutSine
                }
                
                NumberAnimation {
                    from: starWrapper.y - (3 + Math.random() * 8)
                    to: starWrapper.y
                    duration: 15000 + Math.random() * 10000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
