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

    component SectionHeader: Item {
        property string number: ""
        property string icon: ""
        property string title: ""
        property string description: ""

        Layout.fillWidth: true
        implicitHeight: 62

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            spacing: 13

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 12
                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 1, 0.13)
                border.width: 1
                border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.20) : Qt.rgba(0.4, 0.4, 1, 0.20)
                Text {
                    anchors.centerIn: parent
                    text: parent.parent.parent.icon
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: root.theme ? root.theme.accentPrimary : "#8888DD"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: parent.parent.parent.title
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Text {
                    text: parent.parent.parent.description
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }

            Text {
                text: parent.parent.number
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.letterSpacing: 1.2
                font.weight: Font.Bold
                color: root.theme ? root.theme.textMuted : "#666"
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.rgba(255, 255, 255, 0.05)
        }
    }

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
        contentHeight: settingsColumn.implicitHeight + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: settingsColumn
            width: settingsFlickable.width - (settingsFlickable.contentHeight > settingsFlickable.height ? 10 : 0)
            spacing: 16

            SettingsCard {
                title: "Runtime Bridge"
                subtitle: "Manage the background Node.js process and context memory budget"

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
                        text: "Context " + Math.round(ConversationService.contextCharacterCount / 1000)
                            + "k / " + Math.round(ConversationService.contextCharacterBudget / 1000) + "k chars"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        color: ConversationService.contextNearLimit ? "#e6b566" : root.subText
                    }

                    Text {
                        visible: ConversationService.hasContextSummary
                        text: "summarized"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.accent
                    }

                    Text {
                        visible: ConversationService.hasContextSummary && !ConversationService.isGenerating
                        text: "Reset"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.mutedText

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ConversationService.clearContextSummary()
                        }
                    }
                }
            }

            SectionHeader {
                number: "01"
                icon: "auto_awesome"
                title: "Google Gemini"
                description: "Cloud multimodal intelligence API backend"
            }

            AiProviderSettingsCard {
                providerId: "gemini"
                providerName: "Gemini"
                theme: root.theme
            }

            SectionHeader {
                number: "02"
                icon: "bolt"
                title: "Groq Cloud"
                description: "Ultra-high speed Llama & Mixtral inference engine"
            }

            AiProviderSettingsCard {
                providerId: "groq"
                providerName: "Groq"
                theme: root.theme
            }

            SectionHeader {
                number: "03"
                icon: "terminal"
                title: "Ollama Local Server"
                description: "Self-hosted local AI daemon, memory allocation & custom prompts"
            }

            AiProviderSettingsCard {
                providerId: "ollama"
                providerName: "Ollama"
                theme: root.theme
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

            Item { Layout.preferredHeight: 16 }
        }
    }
}
