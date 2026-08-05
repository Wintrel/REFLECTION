import QtQuick
import QtQuick.Controls
import "../../../../core/state" as State

Item {
    id: root

    property var theme: null
    property string query: ""
    property string lastPrompt: ""
    signal suggestionRequested(string suggestion)

    function submitDraft() {
        var prompt = query.trim();
        if (prompt.length === 0)
            return;

        lastPrompt = prompt;
        suggestionRequested("");
    }

    readonly property color accent: theme ? theme.accentPrimary : "#ff9900"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"

    Column {
        anchors.fill: parent
        spacing: 12

        Item {
            id: assistantHeader
            width: parent.width
            height: 32

            Rectangle {
                id: assistantIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)

                Text {
                    anchors.centerIn: parent
                    text: "auto_awesome"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: root.accent
                }
            }

            Column {
                anchors.left: assistantIcon.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "Reflection Assistant"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.mainText
                }

                Text {
                    text: "UI preview"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: root.subText
                }
            }

            Rectangle {
                id: connectionBadge
                anchors.right: openWorkspaceButton.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 104
                height: 24
                radius: 12
                color: Qt.rgba(root.subText.r, root.subText.g, root.subText.b, 0.08)

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.subText
                        opacity: 0.55
                    }

                    Text {
                        text: "Not connected"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.subText
                    }
                }
            }

            Rectangle {
                id: openWorkspaceButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 30
                radius: 10
                color: workspaceMouse.containsMouse
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
                    : Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.035)
                border.width: 1
                border.color: workspaceMouse.containsMouse
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.30)
                    : Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: "open_in_full"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 16
                    color: workspaceMouse.containsMouse ? root.accent : root.subText
                }

                MouseArea {
                    id: workspaceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        State.ReflectionState.close();
                        State.GlobalStates.openAssistantWorkspace();
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - assistantHeader.height - footerHint.implicitHeight - 24
            radius: 18
            color: Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.035)
            border.width: 1
            border.color: Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.07)

            Column {
                id: emptyState
                anchors.centerIn: parent
                width: parent.width - 48
                spacing: 14
                visible: root.lastPrompt.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.query.length > 0 ? "Ready when you are" : "What can I help you with?"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: root.mainText
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.query.length > 0
                        ? "Press Enter to preview this prompt in the conversation."
                        : "Start with a prompt or choose an idea. The AI connection comes in the next milestone."
                    wrapMode: Text.WordWrap
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.subText
                }

                Flow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width, 430)
                    spacing: 8
                    visible: root.query.length === 0

                    Repeater {
                        model: ["Summarize my clipboard", "Help me write", "Explain an error"]

                        Rectangle {
                            required property string modelData
                            width: suggestionText.implicitWidth + 24
                            height: 32
                            radius: 16
                            color: suggestionMouse.containsMouse
                                ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
                                : Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.055)
                            border.width: 1
                            border.color: suggestionMouse.containsMouse
                                ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)
                                : Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.08)

                            Text {
                                id: suggestionText
                                anchors.centerIn: parent
                                text: modelData
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                color: root.mainText
                            }

                            MouseArea {
                                id: suggestionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.suggestionRequested(modelData)
                            }
                        }
                    }
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                visible: root.lastPrompt.length > 0

                Rectangle {
                    anchors.right: parent.right
                    width: Math.min(promptText.implicitWidth + 28, parent.width * 0.82)
                    height: promptText.implicitHeight + 20
                    radius: 14
                    color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)

                    Text {
                        id: promptText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: root.lastPrompt
                        wrapMode: Text.WordWrap
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.mainText
                    }
                }

                Rectangle {
                    width: parent.width * 0.86
                    height: 78
                    radius: 14
                    color: Qt.rgba(root.mainText.r, root.mainText.g, root.mainText.b, 0.045)

                    Row {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "neurology"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: root.accent
                        }

                        Column {
                            width: parent.width - 28
                            spacing: 4

                            Text {
                                text: "The assistant service is not connected yet."
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: root.mainText
                            }

                            Text {
                                width: parent.width
                                text: "This preview confirms the prompt and conversation layout. Provider setup, streaming, and actions come next."
                                wrapMode: Text.WordWrap
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 11
                                color: root.subText
                            }
                        }
                    }
                }
            }
        }

        Text {
            id: footerHint
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Tab toggles Assistant  •  Esc closes Reflection"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 10
            color: root.subText
            opacity: 0.6
        }
    }
}
