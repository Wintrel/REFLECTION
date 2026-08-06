import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/rog" as Rog

// ROG category stage — performance, power & lighting controls
CategoryStage {
    id: root
    categoryTitle: "ROG"
    categorySubtitle: "Performance, power & Aura lighting"

    // ── Shared inline components (matching Shell / Display stages) ────────

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

    // ── Page content 

    pageContent: Flickable {
        id: rogFlickable
        contentWidth: width
        contentHeight: rogBoard.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: rogBoard
            width: rogFlickable.width
            readonly property bool compact: width < 820
            readonly property real columnWidth: compact ? width : (width - 16) / 2
            implicitHeight: compact
                ? macrosCard.y + macrosCard.height + 8
                : Math.max(auraCard.y + auraCard.height, macrosCard.y + macrosCard.height) + 8

            // ── Left column 

            // Performance & GPU — closely related, grouped together
            SettingsCard {
                id: performanceCard
                width: rogBoard.columnWidth
                height: implicitHeight
                x: 0
                y: 0
                title: "Performance & GPU"
                subtitle: "Choose a thermal profile and configure MUX switch GPU routing."

                Rog.PerformanceCard { theme: root.theme }

                // Subtle divider between performance and GPU sections
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.055)
                }

                Text {
                    text: "GPU Mode (MUX Switch)"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Rog.GpuModeCard { theme: root.theme }
            }

            // Aura Sync — lighting section
            SettingsCard {
                id: auraCard
                width: rogBoard.columnWidth
                height: implicitHeight
                x: 0
                y: performanceCard.y + performanceCard.height + 16
                title: "Aura Sync"
                subtitle: "Keyboard backlight brightness and animation effects."

                Rog.AuraCard { theme: root.theme }
            }

            // ── Right column 

            // Battery Care
            SettingsCard {
                id: batteryCard
                width: rogBoard.columnWidth
                height: implicitHeight
                x: rogBoard.compact ? 0 : rogBoard.columnWidth + 16
                y: rogBoard.compact ? auraCard.y + auraCard.height + 16 : 0
                title: "Battery Care"
                subtitle: "Limit maximum charge level to prolong long-term battery health."

                Rog.BatteryCareCard { theme: root.theme }
            }

            // Macros
            SettingsCard {
                id: macrosCard
                width: rogBoard.columnWidth
                height: implicitHeight
                x: rogBoard.compact ? 0 : rogBoard.columnWidth + 16
                y: rogBoard.compact
                    ? batteryCard.y + batteryCard.height + 16
                    : batteryCard.y + batteryCard.height + 16
                title: "Macro Keys"
                subtitle: "Assign actions to your laptop's dedicated macro keys."

                Rog.MacroCard { theme: root.theme }
            }
        }
    }
}
