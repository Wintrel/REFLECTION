pragma Singleton
import QtQuick

QtObject {
    readonly property int idle: 0
    readonly property int hover: 1
    readonly property int expanded: 2
    readonly property int notification: 3
    readonly property int notificationHistory: 4
    readonly property int osd: 5
    readonly property int prompt: 6
    readonly property int actionProgress: 7
    readonly property int reflectionGrid: 8
    readonly property int battery: 9
    readonly property int polkitAuth: 10
    readonly property int settingsHub: 11
    readonly property int filePicker: 12
    readonly property int ciderExpanded: 13
    readonly property int clipboard: 14
}
