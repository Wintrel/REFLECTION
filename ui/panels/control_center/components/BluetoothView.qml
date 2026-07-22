import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"
import "."

ControlCenterMenu {
    id: bluetoothMenu
    
    property var ccRoot
    
    anchors.fill: parent
    anchors.margins: 24
    theme: ccRoot ? ccRoot.theme : null
    title: "Bluetooth Devices"
    opacity: (ccRoot && ccRoot.viewState === "bluetooth") ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    onBackClicked: {
        if (ccRoot) ccRoot.viewState = "main"
    }
    
    model: BluetoothService.bluetoothDevices
    delegate: Item {
        width: parent.width
        height: 52
        
        Item {
            anchors.fill: parent
            scale: maBt.pressed ? 0.97 : 1
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: maBt.pressed ? (bluetoothMenu.theme ? bluetoothMenu.theme.accentPrimary : "#ff9900")
                     : (model.connected ? (bluetoothMenu.theme ? bluetoothMenu.theme.accentSecondary : "#5611f8")
                                        : Qt.rgba(255,255,255,0.03))
                
                border.width: 1
                border.color: (maBt.pressed || model.connected) ? "transparent"
                            : (maBt.containsMouse ? (bluetoothMenu.theme ? bluetoothMenu.theme.accentPrimary : "#ff9900")
                                                  : "transparent")
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }
            }
            
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12
                
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: model.connected ? Qt.rgba(255,255,255,0.1) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: model.icon === "audio-headset" ? "headphones" : (model.icon === "input-mouse" ? "mouse" : "bluetooth")
                        font.family: bluetoothMenu.theme ? bluetoothMenu.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: bluetoothMenu.theme ? bluetoothMenu.theme.textMain : "#FFF"
                        anchors.centerIn: parent
                    }
                }

                Text {
                    text: model.name || model.mac
                    font.family: bluetoothMenu.theme ? bluetoothMenu.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: bluetoothMenu.theme ? bluetoothMenu.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        MouseArea {
            id: maBt
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    BluetoothService.forgetDevice(model.mac, model.name);
                } else {
                    if (model.connected) {
                        BluetoothService.disconnectDevice(model.mac, model.name);
                    } else {
                        BluetoothService.connectDevice(model.mac, model.trusted, model.name, model.icon);
                    }
                    // Close the Control Center to let the Island take over
                    if (ccRoot) ccRoot.viewState = "main";
                    var w = ccRoot;
                    while (w && !w.hasOwnProperty("closePanel")) {
                        w = w.parent;
                    }
                    if (w) w.closePanel();
                }
            }
        }
    }
}
