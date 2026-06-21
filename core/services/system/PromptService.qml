pragma Singleton
import QtQuick
import "../../../core/state" as State

Item {
    id: root

    property string promptType: ""
    property string promptTitle: ""
    property string promptSubtitle: ""
    property string promptTarget: ""
    property string promptIcon: ""
    property string promptCode: ""
    property bool isPassword: true

    signal submitted(string text)
    signal canceled()
    signal promptRequested()

    function requestWifiPassword(ssid) {
        promptType = "wifi";
        promptTitle = "Wi-Fi Security";
        promptSubtitle = ssid;
        promptIcon = "wifi_password";
        promptTarget = ssid;
        isPassword = true;
        promptCode = "";
        
        promptRequested();
    }

    function requestBluetoothPasskey(mac, code) {
        promptType = "bluetooth_passkey";
        promptTitle = "Bluetooth Pairing";
        
        // Format code as "123 456" if it's 6 digits
        if (code && code.length === 6) {
            promptCode = code.substring(0, 3) + " " + code.substring(3);
        } else {
            promptCode = code;
        }
        
        promptIcon = "bluetooth";
        promptTarget = mac;
        isPassword = false;
        
        promptRequested();
    }

    function requestBluetoothPin(mac) {
        promptType = "bluetooth_pin";
        promptTitle = "Enter Bluetooth PIN";
        promptIcon = "dialpad";
        promptTarget = mac;
        isPassword = false;
        
        promptRequested();
    }

    function submit(text) {
        submitted(text);
    }
    
    function cancel() {
        canceled();
    }
}
