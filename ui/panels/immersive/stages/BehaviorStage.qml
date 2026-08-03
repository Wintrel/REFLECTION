import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../control_center/components" as CC

// Behavior category stage — slow concentric rings ambient
CategoryStage {
    id: root
    categoryTitle: "Behavior"
    categorySubtitle: "Shell interaction & automation"

    component ToggleRow: Rectangle {
        id: toggleRow
        property string icon: ""
        property string title: ""
        property string description: ""
        property bool checked: false
        signal toggled(bool checked)

        Layout.fillWidth: true
        implicitHeight: 68
        radius: 12
        color: toggleArea.containsMouse ? Qt.rgba(255, 255, 255, 0.045) : Qt.rgba(255, 255, 255, 0.018)
        border.width: 1
        border.color: checked
            ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.34) : Qt.rgba(0.5, 0.5, 1, 0.34))
            : Qt.rgba(255, 255, 255, 0.055)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 14
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 10
                color: toggleRow.checked
                    ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15) : Qt.rgba(0.5, 0.5, 1, 0.15))
                    : Qt.rgba(255, 255, 255, 0.035)

                Text {
                    anchors.centerIn: parent
                    text: toggleRow.icon
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 19
                    color: toggleRow.checked && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: toggleRow.title
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: toggleRow.description
                    elide: Text.ElideRight
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 24
                radius: 12
                color: toggleRow.checked ? (root.theme ? root.theme.accentPrimary : "#7373D9") : Qt.rgba(255, 255, 255, 0.10)

                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: toggleRow.checked ? parent.width - width - 3 : 3
                    color: toggleRow.checked && root.theme ? root.theme.bgBase : "#F3F3F6"
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }
            }
        }

        MouseArea {
            id: toggleArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleRow.toggled(!toggleRow.checked)
        }
    }

    component SettingsCard: Rectangle {
        default property alias content: cardContent.data
        property string title: ""
        property string subtitle: ""

        Layout.fillWidth: true
        implicitHeight: cardContent.implicitHeight + 40
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.72) : Qt.rgba(0.08, 0.08, 0.10, 0.72)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.065)

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: parent.parent.title
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 17
                font.weight: Font.Bold
                color: root.theme ? root.theme.textMain : "#FFF"
            }

            Text {
                Layout.fillWidth: true
                text: parent.parent.subtitle
                wrapMode: Text.Wrap
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 11
                color: root.theme ? root.theme.textSub : "#888"
            }
        }
    }

    ambientContent: Item {
        // Slow breathing concentric rings — pure Rectangle borders
        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                property real baseSize: Math.min(parent.width, parent.height) * (0.25 + index * 0.18)
                anchors.centerIn: parent
                width: baseSize
                height: baseSize
                radius: baseSize / 2
                color: "transparent"
                border.width: 1
                border.color: root.theme ?
                    Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, Math.max(0.01, 0.06 - index * 0.01)) :
                    Qt.rgba(0.3, 0.3, 0.7, Math.max(0.01, 0.06 - index * 0.01))

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: root.isCurrentPage
                    PauseAnimation { duration: index * 600 }
                    NumberAnimation { to: 1.04; duration: 3000 + index * 400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 3000 + index * 400; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    pageContent: Flickable {
        id: behaviorFlickable
        contentWidth: width
        contentHeight: settingsColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: settingsColumn
            width: behaviorFlickable.width
            spacing: 16

            SettingsCard {
                title: "Super + I"
                subtitle: "A tap opens Quick Settings. Continue holding to enter the immersive control room."

                Text {
                    Layout.fillWidth: true
                    text: "Hold threshold  ·  " + BehaviorService.settingsHoldDuration + " ms"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: root.theme
                    icon: "timer"
                    value: (BehaviorService.settingsHoldDuration - 250) / 7.5
                    valueText: BehaviorService.settingsHoldDuration + " ms"
                    onValueChangedByUser: value => BehaviorService.setSettingsHoldDuration(250 + value * 7.5)
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "250 ms"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.textMuted : "#666"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "1000 ms"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.textMuted : "#666"
                    }
                }

                ToggleRow {
                    icon: "flare"
                    title: "Hold feedback"
                    description: "Charge the island edge while the shortcut is held"
                    checked: BehaviorService.holdFeedbackEnabled
                    onToggled: checked => BehaviorService.setHoldFeedbackEnabled(checked)
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 820 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SettingsCard {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: "Notifications"
                    subtitle: "Choose when the island should ask for your attention."

                    ToggleRow {
                        icon: "do_not_disturb_on"
                        title: "Do Not Disturb"
                        description: "Keep notifications in history without interrupting"
                        checked: BehaviorService.dndEnabled
                        onToggled: checked => BehaviorService.setDndEnabled(checked)
                    }

                    ToggleRow {
                        icon: "volume_up"
                        title: "Notification sound"
                        description: "Play the system message sound for new alerts"
                        checked: BehaviorService.notificationSoundEnabled
                        onToggled: checked => BehaviorService.setNotificationSoundEnabled(checked)
                    }

                    Text {
                        text: "Visible for  ·  " + (BehaviorService.notificationTimeout / 1000).toFixed(1) + " s"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }

                    CC.ThickSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "notifications_active"
                        value: (BehaviorService.notificationTimeout - 2000) / 100
                        valueText: (BehaviorService.notificationTimeout / 1000).toFixed(1) + " s"
                        onValueChangedByUser: value => BehaviorService.setNotificationTimeout(2000 + value * 100)
                    }
                }

                SettingsCard {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: "On-screen feedback"
                    subtitle: "Control routine volume and brightness feedback in the island. Critical warnings always remain visible."

                    ToggleRow {
                        icon: "instant_mix"
                        title: "Routine OSD"
                        description: "Show feedback for volume, brightness and devices"
                        checked: BehaviorService.routineOsdEnabled
                        onToggled: checked => BehaviorService.setRoutineOsdEnabled(checked)
                    }

                    Text {
                        text: "Visible for  ·  " + (BehaviorService.osdTimeout / 1000).toFixed(1) + " s"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }

                    CC.ThickSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "pace"
                        value: (BehaviorService.osdTimeout - 1000) / 50
                        valueText: (BehaviorService.osdTimeout / 1000).toFixed(1) + " s"
                        onValueChangedByUser: value => BehaviorService.setOsdTimeout(1000 + value * 50)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 8
            }
        }
    }
}
