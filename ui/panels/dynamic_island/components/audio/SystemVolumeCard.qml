import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../control_center/components" as CC
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8
    
    Text {
        text: "System Volume"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        text: "Adjust the master system output volume."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
    
    CC.ThickSlider {
        Layout.fillWidth: true
        theme: root.theme
        icon: VolumeService.isMuted ? "volume_off" : "volume_up"
        
        property real internalValue: VolumeService.volume * 100
        value: internalValue
        
        onValueChangedByUser: (val) => {
            internalValue = val;
            VolumeService.setVolume(val);
        }
    }
}
