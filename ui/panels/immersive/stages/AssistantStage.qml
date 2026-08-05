import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/ai"

CategoryStage {
    id: root
    categoryTitle: "Assistant"
    categorySubtitle: "Providers, models & local AI services"

    readonly property color accent: root.theme ? root.theme.accentPrimary : "#8c8cff"
    readonly property color mainText: root.theme ? root.theme.textMain : "#ffffff"
    readonly property color subText: root.theme ? root.theme.textSub : "#a6adc8"
    readonly property color mutedText: root.theme ? root.theme.textMuted : "#707080"

    function daemonStatusLabel() {
        var status = ConversationService.daemonStatus;
        return status.length > 0 ? status.charAt(0).toUpperCase() + status.substring(1) : "Unknown";
    }

    component ProviderChoice: Rectangle {
        id: choice
        required property string providerId
        required property string providerName
        readonly property bool selected: ConversationService.providerId === providerId
        readonly property bool configured: providerId === "groq"
            ? ConversationService.groqConfigured : ConversationService.geminiConfigured

        implicitWidth: 104
        implicitHeight: 34
        radius: 10
        color: selected
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.17)
            : (choiceMouse.containsMouse && choiceMouse.enabled
                ? Qt.rgba(255, 255, 255, 0.055) : Qt.rgba(255, 255, 255, 0.025))
        border.width: selected ? 1 : 0
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3)

        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                Layout.preferredWidth: 7
                Layout.preferredHeight: 7
                radius: 4
                color: choice.configured ? root.accent : root.mutedText
            }

            Text {
                text: choice.providerName
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 11
                font.weight: choice.selected ? Font.DemiBold : Font.Normal
                color: choice.configured ? root.mainText : root.mutedText
            }
        }

        MouseArea {
            id: choiceMouse
            anchors.fill: parent
            enabled: choice.configured && !ConversationService.isGenerating
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: ConversationService.setProvider(choice.providerId)
        }
    }

    ambientContent: Item {
        Repeater {
            model: 5
            delegate: Rectangle {
                required property int index
                width: 90 + index * 34
                height: width
                radius: width / 2
                x: parent.width * (0.62 + (index % 2) * 0.12) - width / 2
                y: parent.height * (0.18 + index * 0.14) - height / 2
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.025 + index * 0.006)
            }
        }
    }

    pageContent: Flickable {
        id: settingsFlickable
        contentWidth: width
        contentHeight: settingsColumn.implicitHeight + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: settingsColumn
            width: settingsFlickable.width - (settingsFlickable.contentHeight > settingsFlickable.height ? 10 : 0)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: ConversationService.daemonError.length > 0 ? 144 : 124
                radius: 18
                color: root.theme
                    ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.72)
                    : Qt.rgba(0.08, 0.08, 0.10, 0.72)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.065)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 11

                        Rectangle {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            radius: 5
                            color: ConversationService.daemonHealthy
                                ? root.accent
                                : (ConversationService.daemonStatus === "failed" ? "#ff7373" : "#e6b566")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "AI daemon · " + root.daemonStatusLabel()
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: root.mainText
                            }

                            Text {
                                Layout.fillWidth: true
                                text: ConversationService.daemonError.length > 0
                                    ? ConversationService.daemonError
                                    : "The local provider bridge is responding normally."
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 10
                                color: root.subText
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 34
                            radius: 10
                            color: restartMouse.containsMouse && restartMouse.enabled
                                ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
                                : Qt.rgba(255, 255, 255, 0.04)

                            Text {
                                anchors.centerIn: parent
                                text: ConversationService.daemonStatus === "restarting" ? "Restarting" : "Restart"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: restartMouse.enabled ? root.accent : root.mutedText
                            }

                            MouseArea {
                                id: restartMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !ConversationService.isGenerating
                                    && ConversationService.daemonStatus !== "restarting"
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: ConversationService.restartDaemon()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(255, 255, 255, 0.055)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Active provider"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: root.subText
                        }

                        Item { Layout.fillWidth: true }

                        ProviderChoice { providerId: "groq"; providerName: "Groq" }
                        ProviderChoice { providerId: "gemini"; providerName: "Gemini" }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 760 ? 2 : 1
                columnSpacing: 12
                rowSpacing: 12

                AiProviderSettingsCard {
                    providerId: "groq"
                    providerName: "Groq"
                    theme: root.theme
                }

                AiProviderSettingsCard {
                    providerId: "gemini"
                    providerName: "Gemini"
                    theme: root.theme
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                radius: 15
                color: Qt.rgba(255, 255, 255, 0.022)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "shield_lock"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 19
                        color: root.accent
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Stored keys remain hidden. Leave a key field empty to keep the existing key. Settings are stored locally with restricted permissions."
                        wrapMode: Text.WordWrap
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.subText
                    }
                }
            }
        }
    }
}
