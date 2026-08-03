import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../../core/services/system"
import "../../../../core/state" as State
import "../../control_center/components" as CC

// Shell category stage — blinking cursor + code-line bars ambient
CategoryStage {
    id: root
    categoryTitle: "Shell"
    categorySubtitle: "Layout, components & features"

    component SettingsCard: Rectangle {
        default property alias content: cardColumn.data
        property string title: ""
        property string subtitle: ""

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        implicitHeight: cardColumn.implicitHeight + 40
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.72) : Qt.rgba(0.08, 0.08, 0.10, 0.72)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.065)

        ColumnLayout {
            id: cardColumn
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

    component ToggleRow: Rectangle {
        id: toggleRow
        property string icon: ""
        property string title: ""
        property string description: ""
        property bool checked: false
        signal toggled(bool checked)

        Layout.fillWidth: true
        implicitHeight: 64
        radius: 12
        color: toggleArea.containsMouse ? Qt.rgba(255, 255, 255, 0.045) : Qt.rgba(255, 255, 255, 0.018)
        border.width: 1
        border.color: checked && root.theme
            ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.34)
            : Qt.rgba(255, 255, 255, 0.055)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 9
                color: toggleRow.checked && root.theme
                    ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15)
                    : Qt.rgba(255, 255, 255, 0.035)

                Text {
                    anchors.centerIn: parent
                    text: toggleRow.icon
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: toggleRow.checked && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
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
                    font.pixelSize: 10
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

    component SegmentedControl: Rectangle {
        id: segmented
        property var options: []
        property int currentIndex: 0
        signal selected(int index)

        Layout.fillWidth: true
        implicitHeight: 44
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.025)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.055)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            Repeater {
                model: segmented.options
                Rectangle {
                    required property int index
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 9
                    property bool selectedOption: index === segmented.currentIndex
                    color: selectedOption && root.theme
                        ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.17)
                        : (segmentArea.containsMouse ? Qt.rgba(255, 255, 255, 0.045) : "transparent")
                    border.width: selectedOption ? 1 : 0
                    border.color: selectedOption && root.theme ? root.theme.accentPrimary : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        font.weight: parent.selectedOption ? Font.DemiBold : Font.Normal
                        color: parent.selectedOption && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                    }

                    MouseArea {
                        id: segmentArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: segmented.selected(index)
                    }
                }
            }
        }
    }

    component ActionButton: Rectangle {
        id: actionButton
        property string icon: ""
        property string label: ""
        property bool destructive: false
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 46
        radius: 12
        color: actionArea.containsMouse
            ? (destructive ? Qt.rgba(1, 0.25, 0.25, 0.10) : Qt.rgba(255, 255, 255, 0.06))
            : Qt.rgba(255, 255, 255, 0.025)
        border.width: 1
        border.color: actionArea.containsMouse && root.theme ? root.theme.accentPrimary : Qt.rgba(255, 255, 255, 0.06)

        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: actionButton.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: actionButton.destructive ? "#ff7777" : (root.theme ? root.theme.accentPrimary : "#AAA")
            }
            Text {
                text: actionButton.label
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: root.theme ? root.theme.textMain : "#FFF"
            }
        }

        MouseArea {
            id: actionArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionButton.clicked()
        }
    }

    pageContent: Flickable {
        id: shellFlickable
        contentWidth: width
        contentHeight: shellBoard.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: shellBoard
            width: shellFlickable.width
            readonly property bool compact: width < 820
            readonly property real columnWidth: compact ? width : (width - 16) / 2
            implicitHeight: compact
                ? maintenanceCard.y + maintenanceCard.height + 8
                : Math.max(featuresCard.y + featuresCard.height, maintenanceCard.y + maintenanceCard.height) + 8

            SettingsCard {
                id: islandCard
                width: shellBoard.columnWidth
                height: implicitHeight
                x: 0
                y: 0
                title: "Dynamic Island"
                subtitle: "Tune its idle presence without disabling authentication, settings, or system prompts."

                Text {
                    text: "Idle presence"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                SegmentedControl {
                    options: ["Minimal", "Contextual", "Full"]
                    currentIndex: ShellService.islandIdleMode
                    onSelected: index => ShellService.setIslandIdleMode(index)
                }
                ToggleRow {
                    icon: "graphic_eq"
                    title: "Media activity"
                    description: "Show playback activity while the island is idle"
                    checked: ShellService.islandMediaActivity
                    onToggled: checked => ShellService.setIslandMediaActivity(checked)
                }
                ToggleRow {
                    icon: "notifications_active"
                    title: "Notification previews"
                    description: "Let new alerts expand the island and appear at idle"
                    checked: ShellService.islandNotificationPreviews
                    onToggled: checked => ShellService.setIslandNotificationPreviews(checked)
                }
                Text {
                    text: "Hold-light intensity"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: root.theme
                    icon: "flare"
                    value: ShellService.holdIndicatorIntensity * 100
                    onValueChangedByUser: value => ShellService.setHoldIndicatorIntensity(value / 100)
                }
            }

            SettingsCard {
                id: taskbarCard
                width: shellBoard.columnWidth
                height: implicitHeight
                x: shellBoard.compact ? 0 : shellBoard.columnWidth + 16
                y: shellBoard.compact ? islandCard.y + islandCard.height + 16 : 0
                title: "Taskbar"
                subtitle: "Control when the taskbar appears and how much room its applications receive."

                ToggleRow {
                    icon: "dock_to_bottom"
                    title: "Taskbar"
                    description: "Keep the Reflection taskbar available"
                    checked: ShellService.taskbarEnabled
                    onToggled: checked => ShellService.setTaskbarEnabled(checked)
                }
                Text {
                    text: "Visibility"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                SegmentedControl {
                    enabled: ShellService.taskbarEnabled
                    opacity: enabled ? 1 : 0.45
                    options: ["Intelligent", "Always", "Edge reveal"]
                    currentIndex: ShellService.taskbarVisibilityMode
                    onSelected: index => ShellService.setTaskbarVisibilityMode(index)
                }
                ToggleRow {
                    icon: "pin"
                    title: "Workspace numbers"
                    description: "Replace workspace dots with persistent numbers"
                    checked: ShellService.workspaceNumbers
                    onToggled: checked => ShellService.setWorkspaceNumbers(checked)
                }
                Text {
                    text: "Bar height  ·  " + ShellService.taskbarHeight + " px"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: root.theme
                    icon: "height"
                    value: (ShellService.taskbarHeight - 44) / 0.24
                    valueText: ShellService.taskbarHeight + " px"
                    onValueChangedByUser: value => ShellService.setTaskbarHeight(44 + value * 0.24)
                }
                Text {
                    text: "Application icons  ·  " + ShellService.taskbarIconSize + " px"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: root.theme
                    icon: "apps"
                    value: (ShellService.taskbarIconSize - 22) / 0.14
                    valueText: ShellService.taskbarIconSize + " px"
                    onValueChangedByUser: value => ShellService.setTaskbarIconSize(22 + value * 0.14)
                }
            }

            SettingsCard {
                id: featuresCard
                width: shellBoard.columnWidth
                height: implicitHeight
                x: 0
                y: shellBoard.compact
                    ? taskbarCard.y + taskbarCard.height + 16
                    : islandCard.y + islandCard.height + 16
                title: "Reflection features"
                subtitle: "Disabled features close immediately and ignore their shortcuts until restored."

                ToggleRow {
                    icon: "grid_view"
                    title: "Workspace overview"
                    description: "Show the visual workspace and window grid"
                    checked: ShellService.overviewEnabled
                    onToggled: checked => ShellService.setOverviewEnabled(checked)
                }
                ToggleRow {
                    icon: "content_paste"
                    title: "Clipboard history"
                    description: "Allow the island to open cliphist entries"
                    checked: ShellService.clipboardEnabled
                    onToggled: checked => ShellService.setClipboardEnabled(checked)
                }
                ToggleRow {
                    icon: "blur_on"
                    title: "Ambient modes"
                    description: "Enable idle and active visualizer modes"
                    checked: ShellService.ambientEnabled
                    onToggled: checked => ShellService.setAmbientEnabled(checked)
                }
                ToggleRow {
                    icon: "wallpaper"
                    title: "Wallpaper selector"
                    description: "Allow the fullscreen wallpaper browser"
                    checked: ShellService.wallpaperSelectorEnabled
                    onToggled: checked => ShellService.setWallpaperSelectorEnabled(checked)
                }
            }

            SettingsCard {
                id: maintenanceCard
                width: shellBoard.columnWidth
                height: implicitHeight
                x: shellBoard.compact ? 0 : shellBoard.columnWidth + 16
                y: shellBoard.compact
                    ? featuresCard.y + featuresCard.height + 16
                    : taskbarCard.y + taskbarCard.height + 16
                title: "Maintenance"
                subtitle: "Recovery tools remain available even when optional shell features are disabled."

                ActionButton {
                    icon: "restart_alt"
                    label: "Reload Reflection"
                    onClicked: {
                        State.GlobalStates.closeImmersive();
                        reloadTimer.restart();
                    }
                }
                ActionButton {
                    icon: "content_copy"
                    label: diagnosticsProcess.running ? "Copying diagnostics…" : "Copy diagnostics"
                    enabled: !diagnosticsProcess.running
                    opacity: enabled ? 1 : 0.55
                    onClicked: diagnosticsProcess.running = true
                }
                ActionButton {
                    icon: "settings_backup_restore"
                    label: "Reset shell preferences"
                    destructive: true
                    onClicked: ShellService.reset()
                }
            }

        }
    }

    Timer {
        id: reloadTimer
        interval: 560
        repeat: false
        onTriggered: Quickshell.reload(false)
    }

    Process {
        id: diagnosticsProcess
        command: ["sh", "-c", "qs log -c reflection | tail -n 250 | wl-copy"]
    }
}
