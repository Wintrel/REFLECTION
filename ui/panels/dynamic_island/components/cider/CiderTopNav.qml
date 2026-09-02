import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/state" as State

Item {
    id: root

    property int currentTab: 0
    property var theme: null

    signal closeClicked()
    signal tabSelected(int index)

    height: 42

    readonly property var tabItems: [
        { icon: "queue_music", label: "Up Next" },
        { icon: "library_music", label: "Playlists" },
        { icon: "auto_awesome", label: "For You" },
        { icon: "search", label: "Search" },
        { icon: "lyrics", label: "Lyrics" }
    ]

    // ── Left: Collapse / Return to Media Pill Button ─────────────────────
    Rectangle {
        id: collapseBtn
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: collapseMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.1)) : Qt.rgba(255, 255, 255, 0.04)
        border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.25) : Qt.rgba(255, 255, 255, 0.08)
        border.width: 1

        scale: collapseMa.pressed ? 0.88 : (collapseMa.containsMouse ? 1.08 : 1.0)
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "keyboard_arrow_up"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 22
            color: collapseMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: collapseMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeClicked()
        }
    }

    // ── Center: M3 Segmented Pill Capsule ────────────────────────────────
    Rectangle {
        id: segmentedCapsule
        anchors.centerIn: parent
        height: 38
        width: tabsRow.width + 8
        radius: height / 2
        color: root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.05)
        border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.08)
        border.width: 1

        // Sliding Active Indicator Pill
        Rectangle {
            id: activePill
            height: parent.height - 6
            y: 3
            radius: height / 2
            color: root.theme ? root.theme.accentPrimary : "#7C9CFF"

            // Target positioning tracked by repeater item
            property Item currentTarget: tabRepeater.itemAt(root.currentTab)
            x: currentTarget ? (tabsRow.x + currentTarget.x) : 4
            width: currentTarget ? currentTarget.width : 40

            Behavior on x {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.3
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutQuad
                }
            }
        }

        Row {
            id: tabsRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                id: tabRepeater
                model: root.tabItems

                delegate: Item {
                    id: tabItem
                    width: tabContentRow.width + 20
                    height: 32

                    readonly property bool isSelected: root.currentTab === index

                    Row {
                        id: tabContentRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: modelData.icon
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 16
                            color: tabItem.isSelected
                                   ? (root.theme ? root.theme.bgBase : "#000")
                                   : (tabMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: modelData.label
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.bold: tabItem.isSelected
                            color: tabItem.isSelected
                                   ? (root.theme ? root.theme.bgBase : "#000")
                                   : (tabMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: tabMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tabSelected(index)
                    }
                }
            }
        }
    }

    // ── Right: Fullscreen Studio Quick Launcher ──────────────────────────
    Rectangle {
        id: studioLauncherBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: studioMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.1)) : Qt.rgba(255, 255, 255, 0.04)
        border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.25) : Qt.rgba(255, 255, 255, 0.08)
        border.width: 1

        scale: studioMa.pressed ? 0.88 : (studioMa.containsMouse ? 1.08 : 1.0)
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "open_in_new"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 18
            color: studioMa.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textSub : "#A6ADC8")
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: studioMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                State.GlobalStates.openCiderStudioWorkspace();
            }
        }
    }
}
