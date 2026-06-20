pragma Singleton
import QtQuick
import "../../../core/state" as State

Item {
    id: root

    property string promptType: ""
    property string promptTitle: ""
    property string promptTarget: ""
    property string promptIcon: ""
    property bool isPassword: true

    signal submitted(string text)
    signal canceled()
    signal promptRequested()

    function requestWifiPassword(ssid) {
        promptType = "wifi";
        promptTitle = "Enter password for " + ssid;
        promptIcon = "lock";
        promptTarget = ssid;
        isPassword = true;
        
        promptRequested();
    }

    function submit(text) {
        submitted(text);
    }
    
    function cancel() {
        canceled();
    }
}
