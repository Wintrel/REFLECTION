import QtQuick
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
    implicitHeight: viewState === "main" ? 420 : 500

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
        Rectangle {
            anchors.fill: parent
            anchors.margins: theme.taskbarBorderWidth
            radius: parent.radius - 2
            color: theme.bgInner
            
            // Square off bottom inner corners
            Rectangle {
                height: theme.taskbarRadius
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: theme.bgInner
            }
        }
    }
    
    // --- MAIN VIEW (Sliders & Toggles) ---
    Column {
        id: mainView
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24
        opacity: root.viewState === "main" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
        
        // 1. Frequent Controls (Sliders)
        Column {
            width: parent.width
            spacing: 16
            
            property bool isVisible: root.viewState === "main" && root.isOpen
            opacity: (root.viewState === "main" && root.isOpen) ? 1 : 0
            transform: Translate {
                y: (root.viewState === "main" && root.isOpen) ? 0 : -10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            
            // Volume
            ThickSlider {
                width: parent.width
                icon: "volume_up"
                theme: root.theme
                value: VolumeService.volume * 100
                onValueChangedByUser: val => VolumeService.setVolume(val)
                onRightClicked: {
                    VolumeService.scanSinks();
                    root.viewState = "audio";
                }
            }
            
            // Brightness
            ThickSlider {
                width: parent.width
                icon: "light_mode"
                theme: root.theme
                value: BrightnessService.brightness * 100
                onValueChangedByUser: val => BrightnessService.setBrightness(val)
            }
        }
        
        // 2. Toggle Controls (2x2 Grid)
        Grid {
            width: parent.width
            columns: 2
            spacing: 16
            
            property bool isVisible: root.viewState === "main" && root.isOpen
            opacity: (root.viewState === "main" && root.isOpen) ? 1 : 0
            transform: Translate {
                y: (root.viewState === "main" && root.isOpen) ? 0 : 10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            
            QuickToggle {
                width: (parent.width - 16) / 2
                height: 64
                icon: "wifi"
                label: (NetworkService.isWifiEnabled && NetworkService.connectedSsid !== "") ? NetworkService.connectedSsid : "Wi-Fi"
                theme: root.theme
                isActive: NetworkService.isWifiEnabled
                onClicked: NetworkService.toggleWifi()
                onRightClicked: {
                    NetworkService.scanWifi();
                    root.viewState = "wifi";
                }
            }
            QuickToggle {
                width: (parent.width - 16) / 2
                height: 64
                icon: "bluetooth"
                label: "Bluetooth"
                theme: root.theme
                isActive: BluetoothService.isBluetoothEnabled
                onClicked: BluetoothService.toggleBluetooth()
                onRightClicked: {
                    BluetoothService.scanBluetooth();
                    BluetoothService.startActiveScan();
                    root.viewState = "bluetooth";
                }
            }
            QuickToggle {
                width: (parent.width - 16) / 2
                height: 64
                icon: "do_not_disturb_on"
                label: "DND"
                theme: root.theme
                isActive: State.GlobalStates.dndEnabled
                onClicked: State.GlobalStates.dndEnabled = !State.GlobalStates.dndEnabled
            }
            QuickToggle {
                width: (parent.width - 16) / 2
                height: 64
                icon: "nightlight"
                label: "Night Light"
                theme: root.theme
                isActive: NightLightService.isEnabled
                onClicked: NightLightService.toggleNightLight()
            }
        }
        
        // Spacer to push actions to bottom
        Item {
            width: 1
            height: parent.height - y - actionRow.height - 10
        }
        
        // 3. System Actions
        Row {
            id: actionRow
            width: parent.width
            spacing: 16
            
            property bool isVisible: root.viewState === "main" && root.isOpen
            opacity: (root.viewState === "main" && root.isOpen) ? 1 : 0
            transform: Translate {
                y: (root.viewState === "main" && root.isOpen) ? 0 : 15
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            
            SystemAction {
                width: (parent.width - 16) / 2
                icon: "settings"
                label: "Settings"
                theme: root.theme
            }
            SystemAction {
                width: (parent.width - 16) / 2
                icon: "power_settings_new"
                label: "Power"
                theme: root.theme
            }
        }
    }

    // --- WI-FI MENU ---
    ControlCenterMenu {
        id: wifiMenu
        anchors.fill: parent
        anchors.margins: 24
        theme: root.theme
        title: "Wi-Fi Networks"
        opacity: root.viewState === "wifi" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
        onBackClicked: root.viewState = "main"
        
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
                    color: maWifi.pressed ? (root.theme ? root.theme.accentPrimary : "#ff9900")
                         : (model.inUse ? (root.theme ? root.theme.accentWorkspace : "#5611f8")
                                        : Qt.rgba(255,255,255,0.03))
                    
                    border.width: 1
                    border.color: (maWifi.pressed || model.inUse) ? "transparent"
                                : (maWifi.containsMouse ? (root.theme ? root.theme.accentPrimary : "#ff9900")
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
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.textMain : "#FFF"
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
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textMain : "#FFF"
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
                        root.viewState = "main";
                        var w = root;
                        while (w && !w.hasOwnProperty("closePanel")) {
                            w = w.parent;
                        }
                        if (w) w.closePanel();
                    }
                }
            }
        }
    }

    // --- BLUETOOTH MENU ---
    ControlCenterMenu {
        anchors.fill: parent
        anchors.margins: 24
        theme: root.theme
        title: "Bluetooth Devices"
        opacity: root.viewState === "bluetooth" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
        onBackClicked: root.viewState = "main"
        
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
                    color: maBt.pressed ? (root.theme ? root.theme.accentPrimary : "#ff9900")
                         : (model.connected ? (root.theme ? root.theme.accentWorkspace : "#5611f8")
                                            : Qt.rgba(255,255,255,0.03))
                    
                    border.width: 1
                    border.color: (maBt.pressed || model.connected) ? "transparent"
                                : (maBt.containsMouse ? (root.theme ? root.theme.accentPrimary : "#ff9900")
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
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.textMain : "#FFF"
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: model.name || model.mac
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textMain : "#FFF"
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
                        root.viewState = "main";
                        var w = root;
                        while (w && !w.hasOwnProperty("closePanel")) {
                            w = w.parent;
                        }
                        if (w) w.closePanel();
                    }
                }
            }
        }
    }

    // --- AUDIO MENU ---
    ControlCenterMenu {
        anchors.fill: parent
        anchors.margins: 24
        theme: root.theme
        title: "Audio Output"
        opacity: root.viewState === "audio" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
        onBackClicked: root.viewState = "main"
        
        model: VolumeService.audioSinks
        delegate: Item {
            width: parent.width
            height: 52

            Item {
                anchors.fill: parent
                scale: maAudio.pressed ? 0.97 : 1
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: maAudio.pressed ? (root.theme ? root.theme.accentPrimary : "#ff9900")
                         : (model.isDefault ? (root.theme ? root.theme.accentWorkspace : "#5611f8")
                                            : Qt.rgba(255,255,255,0.03))
                    
                    border.width: 1
                    border.color: (maAudio.pressed || model.isDefault) ? "transparent"
                                : (maAudio.containsMouse ? (root.theme ? root.theme.accentPrimary : "#ff9900")
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
                        color: model.isDefault ? Qt.rgba(255,255,255,0.1) : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: model.name.toLowerCase().includes("head") ? "headphones" : "speaker"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.textMain : "#FFF"
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: model.name
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        color: root.theme ? root.theme.textMain : "#FFF"
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 52
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                id: maAudio
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    VolumeService.setDefaultSink(model.sinkId)
                }
            }
        }
    }
}
