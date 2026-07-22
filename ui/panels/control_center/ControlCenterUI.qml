import QtQuick
import "../../components"
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../../core/state" as State
import "../../../core/services/system"
import "components"

Item {
    id: root

    property var theme
    property bool isOpen: false
    
    // State machine for the morphing Control Center
    property string viewState: "main" // "main", "wifi", "bluetooth", "audio"
    
    // Dynamic height that automatically morphs the Taskbar container when changed!
    implicitHeight: viewState === "main" ? 440 : 500

    // The panel background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: theme.taskbarRadius
        color: theme.bgBezel
        
        // Square off the bottom corners to fuse with taskbar
        Rectangle {
            height: theme.taskbarRadius
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: theme.bgBezel
        }
        
        // Inner inset area
        Item {
            anchors.fill: parent
            anchors.margins: theme.taskbarBorderWidth
            
            Item {
                id: innerMask
                anchors.fill: parent
                layer.enabled: true
                
                Rectangle {
                    anchors.fill: parent
                    radius: bg.radius - 2
                    color: theme.bgInner
                }
                
                Rectangle {
                    height: theme.taskbarRadius
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: theme.bgInner
                }
            }
            
            ReflectionGradient {
                theme: root.theme
                startColor: theme.bgInner
                endColor: theme.bgInnerGradientEnd
                anchors.fill: parent
                source: innerMask
            }
        }
    }
    
    MainView {
        ccRoot: root
    }
    
    WifiView {
        ccRoot: root
    }
    
    BluetoothView {
        ccRoot: root
    }
    
    AudioView {
        ccRoot: root
    }
}
