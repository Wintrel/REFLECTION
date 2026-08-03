import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/media"
import "../../dynamic_island/components/audio" as Audio

CategoryStage {
    id: root
    categoryTitle: "Cider Studio"
    categorySubtitle: "Integration health, authentication & audio processing"

    readonly property color musicAccent: theme ? theme.accentMusic : "#7257d9"
    readonly property bool healthy: CiderService.socketConnected && CiderService.apiReachable && CiderService.authenticated

    component Surface: Rectangle {
        default property alias content: surfaceColumn.data
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        implicitHeight: surfaceColumn.implicitHeight + 36
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.74) : Qt.rgba(0.08, 0.08, 0.10, 0.74)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.065)

        ColumnLayout {
            id: surfaceColumn
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
        }
    }

    component StatusTile: Rectangle {
        property string icon: ""
        property string label: ""
        property string detail: ""
        property bool good: false

        Layout.fillWidth: true
        Layout.preferredHeight: 72
        radius: 13
        color: good ? Qt.rgba(0.35, 0.85, 0.65, 0.065) : Qt.rgba(255, 255, 255, 0.025)
        border.width: 1
        border.color: good ? Qt.rgba(0.35, 0.85, 0.65, 0.22) : Qt.rgba(255, 255, 255, 0.06)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 13
            spacing: 11
            Text {
                text: parent.parent.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 20
                color: parent.parent.good ? "#62D6A8" : (root.theme ? root.theme.textSub : "#999")
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: parent.parent.parent.label
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Text {
                    Layout.fillWidth: true
                    text: parent.parent.parent.detail
                    elide: Text.ElideRight
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 9
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }
            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: parent.parent.good ? "#62D6A8" : "#777985"
            }
        }
    }

    component StudioButton: Rectangle {
        id: button
        property string icon: ""
        property string label: ""
        property bool primary: false
        property bool destructive: false
        signal clicked()

        implicitWidth: buttonRow.implicitWidth + 28
        implicitHeight: 42
        radius: 12
        color: primary
            ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, buttonArea.containsMouse ? 0.30 : 0.20)
            : (buttonArea.containsMouse ? Qt.rgba(255, 255, 255, 0.065) : Qt.rgba(255, 255, 255, 0.03))
        border.width: 1
        border.color: destructive ? Qt.rgba(1, 0.35, 0.35, 0.32)
                                      : (primary ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.55) : Qt.rgba(255, 255, 255, 0.07))

        RowLayout {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 7
            Text {
                text: button.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: button.destructive ? "#ff7777" : (button.primary ? root.musicAccent : (root.theme ? root.theme.textSub : "#AAA"))
            }
            Text {
                text: button.label
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: root.theme ? root.theme.textMain : "#FFF"
            }
        }

        MouseArea {
            id: buttonArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    ambientContent: Item {
        Row {
            anchors.centerIn: parent
            spacing: 18
            opacity: 0.06
            Repeater {
                model: [110, 190, 145, 260, 205, 310, 170, 235, 125]
                Rectangle {
                    width: 7
                    height: modelData
                    radius: 4
                    color: root.musicAccent
                }
            }
        }
    }

    pageContent: Flickable {
        id: studioFlickable
        contentWidth: width
        contentHeight: studioLayout.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: studioLayout
            width: studioFlickable.width
            spacing: 16

            Surface {
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 15
                        color: root.healthy ? Qt.rgba(0.35, 0.85, 0.65, 0.11) : Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.14)
                        Text {
                            anchors.centerIn: parent
                            text: root.healthy ? "check_circle" : "music_note"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 25
                            color: root.healthy ? "#62D6A8" : root.musicAccent
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            text: root.healthy ? "Cider integration is healthy" : "Cider needs attention"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.healthy
                                ? "Reflection can reach Cider and the configured token is authorized."
                                : (CiderService.connectionError || "Open Cider, enable its API and verify the credential below.")
                            elide: Text.ElideRight
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                    }
                    StudioButton {
                        icon: "refresh"
                        label: "Test connection"
                        primary: true
                        onClicked: CiderService.testConnection()
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= 780 ? 3 : 1
                    columnSpacing: 10
                    rowSpacing: 10

                    StatusTile {
                        icon: "cable"
                        label: "Realtime socket"
                        detail: CiderService.socketConnected ? "Connected to playback events" : "Waiting for Cider"
                        good: CiderService.socketConnected
                    }
                    StatusTile {
                        icon: "api"
                        label: "REST API"
                        detail: CiderService.apiReachable ? (CiderService.latencyMs + " ms response") : "API endpoint unavailable"
                        good: CiderService.apiReachable
                    }
                    StatusTile {
                        icon: "verified_user"
                        label: "Authorization"
                        detail: CiderService.authenticated ? "Token accepted" : (CiderService.tokenConfigured ? "Token not accepted" : "No token configured")
                        good: CiderService.authenticated
                    }
                }
            }

            Surface {
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Connection & authentication"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: CiderService.tokenConfigured ? "CREDENTIAL STORED" : "TOKEN REQUIRED"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                        color: CiderService.tokenConfigured ? "#62D6A8" : (root.theme ? root.theme.textMuted : "#777")
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Reflection talks only to Cider's local API. Apple Music sign-in remains inside Cider. The API token is stored locally with owner-only permissions."
                    wrapMode: Text.Wrap
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: root.theme ? root.theme.textSub : "#888"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= 780 ? 2 : 1
                    columnSpacing: 12
                    rowSpacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text {
                            text: "API endpoint"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                        TextField {
                            id: endpointField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            text: CiderService.endpoint
                            selectByMouse: true
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            color: root.theme ? root.theme.textMain : "#FFF"
                            placeholderText: "http://127.0.0.1:10767"
                            placeholderTextColor: root.theme ? root.theme.textMuted : "#666"
                            leftPadding: 13
                            rightPadding: 13
                            background: Rectangle {
                                radius: 11
                                color: Qt.rgba(255, 255, 255, 0.025)
                                border.width: 1
                                border.color: endpointField.activeFocus ? root.musicAccent : Qt.rgba(255, 255, 255, 0.07)
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text {
                            text: "API token"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                        TextField {
                            id: tokenField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            selectByMouse: true
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            color: root.theme ? root.theme.textMain : "#FFF"
                            placeholderText: CiderService.tokenConfigured ? "Stored token — enter to replace" : "Enter Cider API token"
                            placeholderTextColor: root.theme ? root.theme.textMuted : "#666"
                            leftPadding: 13
                            rightPadding: 44
                            background: Rectangle {
                                radius: 11
                                color: Qt.rgba(255, 255, 255, 0.025)
                                border.width: 1
                                border.color: tokenField.activeFocus ? root.musicAccent : Qt.rgba(255, 255, 255, 0.07)
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 13
                                anchors.verticalCenter: parent.verticalCenter
                                text: "key"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 17
                                color: root.musicAccent
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    StudioButton {
                        visible: CiderService.tokenConfigured
                        icon: "key_off"
                        label: "Clear credential"
                        destructive: true
                        onClicked: {
                            tokenField.clear()
                            CiderService.clearCredential()
                        }
                    }
                    StudioButton {
                        icon: "save"
                        label: "Save & reconnect"
                        primary: true
                        onClicked: {
                            CiderService.configureIntegration(endpointField.text, tokenField.text)
                            tokenField.clear()
                        }
                    }
                }
            }

            Audio.CiderStudioCard { theme: root.theme }
            Item { Layout.preferredHeight: 16 }
        }
    }

    onIsCurrentPageChanged: if (isCurrentPage) CiderService.testConnection()
}
