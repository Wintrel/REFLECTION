import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../control_center/components" as CC

// Display category stage — dot-grid scan-line ambient
CategoryStage {
    id: root
    categoryTitle: "Display"
    categorySubtitle: "Monitor & visual output"

    property int selectedDisplayIndex: 0
    property real previewBrightness: BrightnessService.brightness * 100
    property real previewTemperature: 42
    property int previewScaleIndex: 0
    property int previewOrientation: 0
    property bool previewNightLight: NightLightService.isEnabled
    property bool previewDisplayEnabled: true
    property bool previewPrimary: true
    property bool previewHdr: false
    property bool previewVrr: false
    property int previewDisplayMode: 0

    readonly property var fallbackDisplays: [{
        name: "eDP-1",
        description: "Built-in display",
        make: "Internal",
        model: "Display",
        width: 1920,
        height: 1080,
        refreshRate: 60,
        x: 0,
        y: 0,
        scale: 1,
        focused: true
    }]
    readonly property var displays: HyprlandService.monitors && HyprlandService.monitors.length > 0
        ? HyprlandService.monitors : fallbackDisplays
    readonly property var selectedDisplay: displays[Math.min(selectedDisplayIndex, displays.length - 1)] || fallbackDisplays[0]

    component SettingsCard: Rectangle {
        default property alias content: cardColumn.data
        property string title: ""
        property string subtitle: ""

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        implicitHeight: cardColumn.implicitHeight + 40
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.74) : Qt.rgba(0.08, 0.08, 0.10, 0.74)
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

    component ControlField: Rectangle {
        id: field
        property string icon: ""
        property string label: ""
        property string value: ""
        property string suffixIcon: "expand_more"

        Layout.fillWidth: true
        implicitHeight: 58
        radius: 12
        color: fieldArea.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.022)
        border.width: 1
        border.color: fieldArea.containsMouse && root.theme ? root.theme.accentPrimary : Qt.rgba(255, 255, 255, 0.06)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 11
            Text {
                text: field.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 19
                color: root.theme ? root.theme.accentPrimary : "#8888DD"
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    text: field.label
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: root.theme ? root.theme.textMuted : "#666"
                }
                Text {
                    text: field.value
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }
            Text {
                text: field.suffixIcon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: root.theme ? root.theme.textSub : "#888"
            }
        }
        MouseArea {
            id: fieldArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
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
                    property bool active: index === segmented.currentIndex
                    color: active && root.theme
                        ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.17)
                        : (segmentArea.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : "transparent")
                    border.width: active ? 1 : 0
                    border.color: active && root.theme ? root.theme.accentPrimary : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        font.weight: parent.active ? Font.DemiBold : Font.Normal
                        color: parent.active && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
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

    component PreviewToggle: Rectangle {
        id: previewToggle
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
            Text {
                text: previewToggle.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 19
                color: previewToggle.checked && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: previewToggle.title
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Text {
                    text: previewToggle.description
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }
            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 24
                radius: 12
                color: previewToggle.checked ? (root.theme ? root.theme.accentPrimary : "#7373D9") : Qt.rgba(255, 255, 255, 0.10)
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: previewToggle.checked ? parent.width - width - 3 : 3
                    color: previewToggle.checked && root.theme ? root.theme.bgBase : "#F3F3F6"
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }
            }
        }
        MouseArea {
            id: toggleArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: previewToggle.toggled(!previewToggle.checked)
        }
    }

    component HeaderAction: Rectangle {
        id: headerAction
        property string icon: ""
        property string label: ""

        Layout.preferredWidth: actionRow.implicitWidth + 22
        Layout.preferredHeight: 30
        radius: 10
        color: actionArea.containsMouse ? Qt.rgba(255, 255, 255, 0.065) : Qt.rgba(255, 255, 255, 0.028)
        border.width: 1
        border.color: actionArea.containsMouse && root.theme ? root.theme.accentPrimary : Qt.rgba(255, 255, 255, 0.06)

        RowLayout {
            id: actionRow
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: headerAction.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 14
                color: root.theme ? root.theme.accentPrimary : "#8888DD"
            }
            Text {
                text: headerAction.label
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                color: root.theme ? root.theme.textMain : "#FFF"
            }
        }
        MouseArea {
            id: actionArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    pageContent: Flickable {
        id: displayFlickable
        contentWidth: width
        contentHeight: displayColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: displayColumn
            width: displayFlickable.width
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                radius: 20
                color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.68) : Qt.rgba(0.08, 0.08, 0.10, 0.68)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.065)
                clip: true

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.18
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: "transparent" }
                        GradientStop { position: 0.5; color: root.theme ? root.theme.accentPrimary : "#5555AA" }
                        GradientStop { position: 1; color: "transparent" }
                    }
                }

                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    Text {
                        text: "Display arrangement"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Item { Layout.fillWidth: true }
                    HeaderAction {
                        icon: "filter_1"
                        label: "Identify"
                    }
                    HeaderAction {
                        icon: "screen_search_desktop"
                        label: "Detect"
                    }
                    Rectangle {
                        Layout.preferredWidth: previewBadgeRow.implicitWidth + 20
                        Layout.preferredHeight: 30
                        radius: 15
                        color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.11) : Qt.rgba(0.4, 0.4, 1, 0.11)
                        RowLayout {
                            id: previewBadgeRow
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "visibility"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 14
                                color: root.theme ? root.theme.accentPrimary : "#8888DD"
                            }
                            Text {
                                text: "DESIGN PREVIEW"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 9
                                font.letterSpacing: 1.1
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accentPrimary : "#8888DD"
                            }
                        }
                    }
                }

                Item {
                    id: arrangementCanvas
                    anchors.fill: parent
                    anchors.topMargin: 60
                    anchors.leftMargin: 32
                    anchors.rightMargin: 32
                    anchors.bottomMargin: 76

                    readonly property real maximumWidth: {
                        var total = 0;
                        for (var i = 0; i < root.displays.length; ++i)
                            total += (root.displays[i].width || 1920) / (root.displays[i].scale || 1);
                        return Math.max(1, total);
                    }
                    readonly property real layoutScale: Math.min(0.18, (width - Math.max(0, root.displays.length - 1) * 18) / maximumWidth)

                    Row {
                        anchors.centerIn: parent
                        spacing: 18
                        Repeater {
                            model: root.displays
                            Rectangle {
                                required property int index
                                required property var modelData
                                readonly property real logicalWidth: (modelData.width || 1920) / (modelData.scale || 1)
                                readonly property real logicalHeight: (modelData.height || 1080) / (modelData.scale || 1)
                                readonly property bool selected: index === root.selectedDisplayIndex
                                width: Math.max(150, logicalWidth * arrangementCanvas.layoutScale)
                                height: Math.max(90, logicalHeight * arrangementCanvas.layoutScale) + 24
                                radius: 12
                                color: selected ? Qt.rgba(255, 255, 255, 0.07) : Qt.rgba(255, 255, 255, 0.025)
                                border.width: selected ? 2 : 1
                                border.color: selected && root.theme ? root.theme.accentPrimary : Qt.rgba(255, 255, 255, 0.10)

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: displayLabel.top
                                    anchors.margins: 6
                                    radius: 8
                                    clip: true
                                    color: root.theme ? root.theme.bgInner : "#09090C"
                                    Image {
                                        anchors.fill: parent
                                        source: WallpaperService.currentWallpaper
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        opacity: 0.34
                                    }
                                    Rectangle {
                                        anchors.fill: parent
                                        gradient: Gradient {
                                            GradientStop { position: 0; color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.24) : Qt.rgba(0.3, 0.3, 0.8, 0.24) }
                                            GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.45) }
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: index + 1
                                        font.family: root.theme ? root.theme.fontMain : "Inter"
                                        font.pixelSize: 28
                                        font.weight: Font.Bold
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Rectangle {
                                        visible: modelData.focused === true
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 8
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: root.theme ? root.theme.accentPrimary : "#7777DD"
                                    }
                                }
                                Text {
                                    id: displayLabel
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: 4
                                    text: (modelData.name || "Display") + "  ·  " + (modelData.width || 1920) + "×" + (modelData.height || 1080)
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 10
                                    color: selected && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectedDisplayIndex = index
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 14
                    height: 48
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.025)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.055)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 8
                            color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.14) : Qt.rgba(0.4, 0.4, 1, 0.14)
                            Text {
                                anchors.centerIn: parent
                                text: root.selectedDisplayIndex + 1
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accentPrimary : "#8888DD"
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: root.selectedDisplay.name || "Display"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: root.theme ? root.theme.textMain : "#FFF"
                            }
                            Text {
                                text: (root.selectedDisplay.width || 1920) + "×" + (root.selectedDisplay.height || 1080)
                                    + "  ·  " + Number(root.selectedDisplay.refreshRate || 60).toFixed(0) + " Hz"
                                    + "  ·  " + Math.round((root.selectedDisplay.scale || 1) * 100) + "%  ·  SDR"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 9
                                color: root.theme ? root.theme.textSub : "#888"
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: connectedRow.implicitWidth + 18
                            Layout.preferredHeight: 26
                            radius: 13
                            color: Qt.rgba(0.35, 0.85, 0.65, 0.09)
                            RowLayout {
                                id: connectedRow
                                anchors.centerIn: parent
                                spacing: 5
                                Rectangle { width: 6; height: 6; radius: 3; color: "#62D6A8" }
                                Text {
                                    text: "CONNECTED"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 8
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    color: "#62D6A8"
                                }
                            }
                        }
                        Rectangle {
                            visible: root.previewPrimary
                            Layout.preferredWidth: 66
                            Layout.preferredHeight: 26
                            radius: 13
                            color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.10) : Qt.rgba(0.4, 0.4, 1, 0.10)
                            Text {
                                anchors.centerIn: parent
                                text: "PRIMARY"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 8
                                font.letterSpacing: 0.8
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accentPrimary : "#8888DD"
                            }
                        }
                    }
                }
            }

            GridLayout {
                id: displaySettingsGrid
                Layout.fillWidth: true
                columns: width >= 820 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SettingsCard {
                    Layout.row: 1
                    Layout.column: 0
                    title: root.selectedDisplay.name || "Display"
                    subtitle: (root.selectedDisplay.description || ((root.selectedDisplay.make || "") + " " + (root.selectedDisplay.model || "")).trim()) || "Connected display"

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 430 ? 2 : 1
                        columnSpacing: 10
                        rowSpacing: 10
                        ControlField {
                            icon: "aspect_ratio"
                            label: "Resolution"
                            value: (root.selectedDisplay.width || 1920) + " × " + (root.selectedDisplay.height || 1080)
                        }
                        ControlField {
                            icon: "speed"
                            label: "Refresh rate"
                            value: Number(root.selectedDisplay.refreshRate || 60).toFixed(0) + " Hz"
                        }
                    }
                    Text {
                        text: "Scale"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    SegmentedControl {
                        options: ["100%", "125%", "150%", "175%"]
                        currentIndex: root.previewScaleIndex
                        onSelected: index => root.previewScaleIndex = index
                    }
                    Text {
                        text: "Orientation"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    SegmentedControl {
                        options: ["Landscape", "Portrait", "Flipped"]
                        currentIndex: root.previewOrientation
                        onSelected: index => root.previewOrientation = index
                    }
                }

                SettingsCard {
                    Layout.row: displaySettingsGrid.columns === 1 ? 2 : 1
                    Layout.column: displaySettingsGrid.columns === 1 ? 0 : 1
                    title: "Light & color"
                    subtitle: "Preview comfort and luminance controls for the selected display."

                    Text {
                        text: "Brightness"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    CC.ThickSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "brightness_6"
                        value: root.previewBrightness
                        onValueChangedByUser: value => root.previewBrightness = value
                    }
                    PreviewToggle {
                        icon: "nightlight"
                        title: "Night Light"
                        description: "Warm the display after sunset"
                        checked: root.previewNightLight
                        onToggled: checked => root.previewNightLight = checked
                    }
                    Text {
                        text: "Color temperature  ·  " + Math.round(6500 - root.previewTemperature * 30) + " K"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    CC.ThickSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "thermostat"
                        value: root.previewTemperature
                        valueText: Math.round(6500 - root.previewTemperature * 30) + " K"
                        onValueChangedByUser: value => root.previewTemperature = value
                    }
                    ControlField {
                        icon: "palette"
                        label: "Color profile"
                        value: "Standard RGB"
                    }
                }

                SettingsCard {
                    Layout.row: 0
                    Layout.column: 0
                    Layout.columnSpan: displaySettingsGrid.columns
                    title: "Display role & capabilities"
                    subtitle: "Choose how this output participates in the desktop and review the features it can expose."

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 820 ? 2 : 1
                        columnSpacing: 12
                        rowSpacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            ControlField {
                                icon: "splitscreen"
                                label: "Multiple displays"
                                value: ["Extend these displays", "Duplicate displays", "Show only on this display"][root.previewDisplayMode]
                            }
                            SegmentedControl {
                                options: ["Extend", "Duplicate", "Only here"]
                                currentIndex: root.previewDisplayMode
                                onSelected: index => root.previewDisplayMode = index
                            }
                            PreviewToggle {
                                icon: "power_settings_new"
                                title: "Use this display"
                                description: "Include this output in the desktop layout"
                                checked: root.previewDisplayEnabled
                                onToggled: checked => root.previewDisplayEnabled = checked
                            }
                            PreviewToggle {
                                icon: "star"
                                title: "Primary display"
                                description: "Prefer this output for new windows and panels"
                                checked: root.previewPrimary
                                onToggled: checked => root.previewPrimary = checked
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            PreviewToggle {
                                icon: "hdr_on"
                                title: "HDR"
                                description: "High dynamic range output · capability preview"
                                checked: root.previewHdr
                                onToggled: checked => root.previewHdr = checked
                            }
                            PreviewToggle {
                                icon: "sync"
                                title: "Variable refresh rate"
                                description: "Adapt refresh timing to rendered frames"
                                checked: root.previewVrr
                                onToggled: checked => root.previewVrr = checked
                            }
                            ControlField {
                                icon: "monitor_heart"
                                label: "Advanced display"
                                value: "Timing, formats and hardware details"
                                suffixIcon: "arrow_forward"
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 16
                color: Qt.rgba(255, 255, 255, 0.018)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.055)
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 12
                    spacing: 12
                    Text {
                        text: "info"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: root.theme ? root.theme.accentPrimary : "#8888DD"
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: "Layout prototype"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                        Text {
                            text: "Controls update this preview only. No monitor configuration is being changed."
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 122
                        Layout.preferredHeight: 38
                        radius: 11
                        color: Qt.rgba(255, 255, 255, 0.035)
                        border.width: 1
                        border.color: Qt.rgba(255, 255, 255, 0.06)
                        opacity: 0.48
                        Text {
                            anchors.centerIn: parent
                            text: "Apply changes"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textSub : "#888"
                        }
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
