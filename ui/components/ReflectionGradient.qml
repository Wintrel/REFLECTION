import QtQuick
import Qt5Compat.GraphicalEffects

LinearGradient {
    id: root
    property var theme
    property color startColor: "transparent"
    property color endColor: "transparent"
    
    // Default to diagonal from top-left to bottom-right
    start: Qt.point(0, 0)
    end: Qt.point(width, height)
    
    gradient: Gradient {
        GradientStop { position: 0.0; color: root.startColor }
        GradientStop { position: 1.0; color: root.endColor }
    }
    
    visible: theme ? theme.useGradients : false
    
    // We bind visibility, but we also ensure if it's visible, it covers its parent
    anchors.fill: parent
    source: parent
}
