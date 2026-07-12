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
            
            // Generate random constants ONCE so they don't re-evaluate on resize
            property real randX: Math.random()
            property real randY: Math.random()
            property real driftDist: 3 + Math.random() * 8
            property int driftTime: 15000 + Math.random() * 10000
            property int pauseTime: Math.random() * 4000
            
            // Bind to the parent's size using the stable random percentages
            x: randX * root.width
            y: randY * root.height
            
            // Randomize size between 1.0 and 2.5 pixels
            property real size: 1.0 + Math.random() * 2.5
            width: size
            height: size
            
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.starColor
                
                // Base opacity is more visible
                opacity: 0.2
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.visible
                    
                    // Random pause at the start so all stars don't shimmer in sync
                    PauseAnimation { duration: Math.random() * 2000 }
                    
                    // Smoothly fade in
                    NumberAnimation { 
                        from: 0.15 
                        to: 0.4 + Math.random() * 0.5 
                        duration: 2000 + Math.random() * 3000
                        easing.type: Easing.InOutSine 
                    }
                    
                    // Smoothly fade out
                    NumberAnimation { 
                        from: 0.4 + Math.random() * 0.5 
                        to: 0.15 
                        duration: 2000 + Math.random() * 3000
                        easing.type: Easing.InOutSine 
                    }
                    
                    // Random pause before shimmering again
                    PauseAnimation { duration: 500 + Math.random() * 1500 }
                }
            }
            
            // Extremely slow, subtle vertical drift to make the void feel 3D and alive
            // We use a Transform so we don't overwrite the y-coordinate binding!
            transform: Translate {
                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: root.visible
                    
                    PauseAnimation { duration: starWrapper.pauseTime }
                    
                    NumberAnimation { 
                        from: 0
                        to: -starWrapper.driftDist
                        duration: starWrapper.driftTime
                        easing.type: Easing.InOutSine
                    }
                    
                    NumberAnimation {
                        from: -starWrapper.driftDist
                        to: 0
                        duration: starWrapper.driftTime
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
