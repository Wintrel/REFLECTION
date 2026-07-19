import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property var theme
    property string imageSource: ""
    property bool active: imageSource !== ""
    
    signal closed()
    signal cropped()
    
    visible: active
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    
    // Reset state when new image is loaded
    onImageSourceChanged: {
        if (imageSource !== "") {
            img.scale = 1.0;
            img.x = 0;
            img.y = 0;
            // Auto fit
            if (img.status === Image.Ready) fitImage();
        }
    }
    
    function fitImage() {
        if (img.sourceSize.width === 0) return;
        var scaleX = 600 / img.sourceSize.width;
        var scaleY = 200 / img.sourceSize.height;
        img.scale = Math.max(scaleX, scaleY);
        img.x = (editorArea.width - (img.sourceSize.width * img.scale)) / 2;
        img.y = (editorArea.height - (img.sourceSize.height * img.scale)) / 2;
    }
    
    Rectangle {
        anchors.fill: parent
        color: root.theme ? root.theme.bgInner : "#111"
        radius: 12
        
        // Editor Area
        Item {
            id: editorArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomBar.top
            clip: true
            
            Image {
                id: img
                source: root.imageSource
                transformOrigin: Item.TopLeft
                asynchronous: true
                onStatusChanged: {
                    if (status === Image.Ready) fitImage();
                }
            }
            
            MouseArea {
                anchors.fill: parent
                drag.target: img
                
                onWheel: (wheel) => {
                    var zoomFactor = wheel.angleDelta.y > 0 ? 1.1 : (1 / 1.1);
                    var oldScale = img.scale;
                    var newScale = oldScale * zoomFactor;
                    
                    // Limit scale
                    if (newScale < 0.1) newScale = 0.1;
                    if (newScale > 10.0) newScale = 10.0;
                    
                    // Zoom towards mouse cursor
                    var mouseX = wheel.x;
                    var mouseY = wheel.y;
                    
                    var relX = (mouseX - img.x) / oldScale;
                    var relY = (mouseY - img.y) / oldScale;
                    
                    img.scale = newScale;
                    img.x = mouseX - (relX * newScale);
                    img.y = mouseY - (relY * newScale);
                }
            }
            
            // Mask overlay (darkens outside the crop circle)
            Rectangle {
                id: darkOverlay
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.7)
                visible: false
            }
            
            Rectangle {
                id: cropCircle
                width: 600
                height: 200
                radius: 12
                anchors.centerIn: parent
                color: "#000000" // Mask color
                visible: false
            }
            
            Item {
                id: invertedMask
                anchors.fill: parent
                visible: false
                Rectangle { anchors.fill: parent; color: "white" }
                Rectangle {
                    width: 600
                    height: 200
                    radius: 12
                    anchors.centerIn: parent
                    color: "transparent"
                    border.width: Math.max(parent.width, parent.height)
                    border.color: "black"
                }
            }
            
            OpacityMask {
                anchors.fill: parent
                source: darkOverlay
                maskSource: invertedMask
                invert: true
            }
            
            // Guide border
            Rectangle {
                anchors.centerIn: parent
                width: 600
                height: 200
                radius: 12
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(255, 255, 255, 0.8)
                
                // Instructions
                Text {
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Scroll to zoom, drag to pan"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: Qt.rgba(255, 255, 255, 0.7)
                }
            }
        }
        
        // Bottom Bar
        Rectangle {
            id: bottomBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            color: Qt.rgba(0, 0, 0, 0.3)
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 24
                
                // Cancel
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    radius: 6
                    color: maCancel.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    MouseArea {
                        id: maCancel
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.imageSource = "";
                            root.closed();
                        }
                    }
                }
                
                // Save
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    radius: 6
                    color: maSave.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Apply"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: maSave.containsMouse ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    MouseArea {
                        id: maSave
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var cropX = cropCircle.x;
                            var cropY = cropCircle.y;
                            var cropW = 600;
                            var cropH = 200;
                            
                            var realX = Math.round((cropX - img.x) / img.scale);
                            var realY = Math.round((cropY - img.y) / img.scale);
                            var realW = Math.round(cropW / img.scale);
                            var realH = Math.round(cropH / img.scale);
                            
                            var inPath = root.imageSource.replace("file://", "");
                            var outPath = Quickshell.env("HOME") + "/.face_banner";
                            
                            var p = Qt.createQmlObject('import Quickshell.Io; Process { ; onExited: destroy() }', root);
                            p.command = ["magick", inPath, "-crop", realW + "x" + realH + "+" + realX + "+" + realY, "-resize", "1200x400", outPath];
                            p.exited.connect(function(code) {
                                if (code === 0) {
                                    root.cropped();
                                    root.imageSource = "";
                                    root.closed();
                                }
                                p.destroy();
                            });
                            p.running = true;
                        }
                    }
                }
            }
        }
    }
}
