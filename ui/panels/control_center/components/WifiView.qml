import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"
import "."

ControlCenterMenu {
    id: wifiMenu
    
    property var ccRoot
    
    anchors.fill: parent
    anchors.margins: 24
    theme: ccRoot ? ccRoot.theme : null
    title: "Wi-Fi Networks"
    opacity: (ccRoot && ccRoot.viewState === "wifi") ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    onBackClicked: {
        if (ccRoot) ccRoot.viewState = "main"
    }
    
    model: NetworkService.wifiNetworks
    delegate: Item {
        width: ListView.view ? ListView.view.width : (parent ? parent.width : 0)
        height: 52
        clip: true

        Item {
            anchors.fill: parent
            scale: maWifi.pressed ? 0.97 : 1
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: maWifi.pressed ? (wifiMenu.theme ? wifiMenu.theme.accentPrimary : "#ff9900")
                     : (model.inUse ? (wifiMenu.theme ? wifiMenu.theme.accentSecondary : "#5611f8")
                                    : Qt.rgba(255,255,255,0.03))
                
                border.width: 1
                border.color: (maWifi.pressed || model.inUse) ? "transparent"
                            : (maWifi.containsMouse ? (wifiMenu.theme ? wifiMenu.theme.accentPrimary : "#ff9900")
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
                    color: model.inUse ? Qt.rgba(255,255,255,0.1) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        id: wifiIcon
                        text: NetworkService.connectingSsid === model.ssid ? "autorenew" : (model.inUse ? "wifi" : (model.security === "" ? "network_wifi" : (model.isKnown ? "wifi_password" : "lock")))
                        font.family: wifiMenu.theme ? wifiMenu.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: wifiMenu.theme ? wifiMenu.theme.textMain : "#FFF"
                        anchors.centerIn: parent
                        
                        RotationAnimator on rotation {
                            running: NetworkService.connectingSsid === model.ssid
                            from: 0; to: 360
                            duration: 1000; loops: Animation.Infinite
                            onRunningChanged: if (!running) wifiIcon.rotation = 0
                        }
                    }
                }

                Text {
                    text: model.ssid
                    font.family: wifiMenu.theme ? wifiMenu.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: wifiMenu.theme ? wifiMenu.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        MouseArea {
            id: maWifi
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    if (model.isKnown) {
                        NetworkService.forgetWifi(model.ssid);
                    }
                } else {
                    if (model.inUse) {
                        NetworkService.disconnectWifi(model.ssid);
                    } else if (model.isKnown || model.security === "") {
                        NetworkService.connectToWifi(model.ssid, "");
                    } else {
                        PromptService.requestWifiPassword(model.ssid);
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
