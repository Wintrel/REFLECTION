import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"
import "."

Column {
    id: mainView
    
    property var ccRoot
    property var theme: ccRoot ? ccRoot.theme : null
    
    anchors.fill: parent
    anchors.margins: 24
    spacing: 24
    opacity: (ccRoot && ccRoot.viewState === "main") ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    
    // 1. Frequent Controls (Sliders)
    Column {
        width: parent.width
        spacing: 16
        
        property bool isVisible: ccRoot && ccRoot.viewState === "main" && ccRoot.isOpen
        opacity: isVisible ? 1 : 0
        transform: Translate {
            y: isVisible ? 0 : -10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

        
        // Volume
        ThickSlider {
            width: parent.width
            icon: "volume_up"
            theme: mainView.theme
            value: VolumeService.volume * 100
            onValueChangedByUser: val => VolumeService.setVolume(val)
            onRightClicked: {
                VolumeService.scanSinks();
                if (ccRoot) ccRoot.viewState = "audio";
            }
        }
        
        // Brightness
        ThickSlider {
            width: parent.width
            icon: "light_mode"
            theme: mainView.theme
            value: BrightnessService.brightness * 100
            onValueChangedByUser: val => BrightnessService.setBrightness(val)
        }
    }
    
    // 2. Toggle Controls (2x2 Grid)
    Grid {
        width: parent.width
        columns: 2
        spacing: 16
        
        property bool isVisible: ccRoot && ccRoot.viewState === "main" && ccRoot.isOpen
        opacity: isVisible ? 1 : 0
        transform: Translate {
            y: isVisible ? 0 : 10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

        
        QuickToggle {
            width: (parent.width - 16) / 2
            height: 64
            icon: "wifi"
            label: (NetworkService.isWifiEnabled && NetworkService.connectedSsid !== "") ? NetworkService.connectedSsid : "Wi-Fi"
            theme: mainView.theme
            isActive: NetworkService.isWifiEnabled
            onClicked: NetworkService.toggleWifi()
            onRightClicked: {
                NetworkService.scanWifi();
                if (ccRoot) ccRoot.viewState = "wifi";
            }
        }
        QuickToggle {
            width: (parent.width - 16) / 2
            height: 64
            icon: "bluetooth"
            label: "Bluetooth"
            theme: mainView.theme
            isActive: BluetoothService.isBluetoothEnabled
            onClicked: BluetoothService.toggleBluetooth()
            onRightClicked: {
                BluetoothService.scanBluetooth();
                BluetoothService.startActiveScan();
                if (ccRoot) ccRoot.viewState = "bluetooth";
            }
        }
        QuickToggle {
            width: (parent.width - 16) / 2
            height: 64
            icon: "do_not_disturb_on"
            label: "DND"
            theme: mainView.theme
            isActive: State.GlobalStates.dndEnabled
            onClicked: State.GlobalStates.dndEnabled = !State.GlobalStates.dndEnabled
        }
        QuickToggle {
            width: (parent.width - 16) / 2
            height: 64
            icon: "nightlight"
            label: "Night Light"
            theme: mainView.theme
            isActive: NightLightService.isEnabled
            onClicked: NightLightService.toggleNightLight()
        }
    }
    
    // Spacer to push actions to bottom
    Item {
        width: 1
        height: Math.max(0, parent.height - y - actionRow.height - 24)
    }
    
    // 3. System Actions
    Row {
        id: actionRow
        width: parent.width
        spacing: 16
        
        property bool isVisible: ccRoot && ccRoot.viewState === "main" && ccRoot.isOpen
        opacity: isVisible ? 1 : 0
        transform: Translate {
            y: isVisible ? 0 : 15
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

        
        SystemAction {
            width: (parent.width - 16) / 2
            icon: "settings"
            label: "Settings"
            theme: mainView.theme
            onClicked: {
                State.GlobalStates.settingsOpen = true;
                var w = ccRoot;
                while (w && !w.hasOwnProperty("closePanel")) {
                    w = w.parent;
                }
                if (w) w.closePanel();
            }
        }
        SystemAction {
            width: (parent.width - 16) / 2
            icon: "power_settings_new"
            label: "Power"
            theme: mainView.theme
        }
    }
}
