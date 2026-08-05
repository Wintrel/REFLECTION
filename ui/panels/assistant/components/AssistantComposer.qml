import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/ai"
import "../../../../core/monitors"
import "../../../../core/state" as State

Rectangle {
    id: composer

    property var theme: null
    property int activeContextCount: 0
    property string activeMode: "Ask"
    property bool compact: false

    property bool clipboardContext: false
    property bool selectionContext: false
    property bool screenContext: false
    property var attachedFiles: []

    signal removeClipboard()
    signal removeSelection()
    signal removeScreen()
    signal removeAttachedFile(string path)
    signal fileAttached(string path)

    signal promptSubmitted(string prompt, string contextPayload, string contextSources, var imagePaths)

    property bool gatheringContext: false

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"
    readonly property color raisedColor: theme ? theme.surfaceOverlay : "#1a1a22"

    function setPrompt(prompt) {
        composerInput.text = prompt;
        composerInput.forceActiveFocus();
    }

    function submitPrompt() {
        var userPrompt = composerInput.text.trim();
        if (userPrompt.length === 0 || ConversationService.isGenerating || composer.gatheringContext)
            return;
        
        composer.gatheringContext = true;
        composerInput.text = "";
        
        var contextText = "";
        var imagePaths = [];
        var stepIndex = 0;
        
        var steps = [
            function() {
                if (composer.clipboardContext) {
                    var clipOut = "";
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["wl-paste"] }', composer);
                    var parser = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
                    parser.read.connect(function(data) { clipOut += data + "\n"; });
                    p.stdout = parser;
                    p.exited.connect(function() {
                        if (clipOut.trim().length > 0)
                            contextText += "<context source=\"clipboard\">\n" + clipOut.trim() + "\n</context>\n\n";
                        p.destroy();
                        nextStep();
                    });
                    p.running = true;
                } else { nextStep(); }
            },
            function() {
                if (composer.selectionContext) {
                    var selOut = "";
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["wl-paste", "-p"] }', composer);
                    var parser = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
                    parser.read.connect(function(data) { selOut += data + "\n"; });
                    p.stdout = parser;
                    p.exited.connect(function() {
                        if (selOut.trim().length > 0)
                            contextText += "<context source=\"selected_text\">\n" + selOut.trim() + "\n</context>\n\n";
                        p.destroy();
                        nextStep();
                    });
                    p.running = true;
                } else { nextStep(); }
            },
            function() {
                if (composer.screenContext) {
                    var path = "/tmp/reflection_screen_" + Date.now() + ".png";
                    imagePaths.push(path);
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["grim", "-o", "' + MonitorService.targetScreenName + '", "' + path + '"] }', composer);
                    p.exited.connect(function() {
                        p.destroy();
                        nextStep();
                    });
                    p.running = true;
                } else { nextStep(); }
            },
            function() {
                if (composer.attachedFiles && composer.attachedFiles.length > 0) {
                    var fileIndex = 0;
                    function processNextFile() {
                        if (fileIndex >= composer.attachedFiles.length) {
                            nextStep();
                            return;
                        }
                        var filePath = composer.attachedFiles[fileIndex];
                        var lowerPath = filePath.toLowerCase();
                        fileIndex++;
                        
                        if (lowerPath.endsWith(".png") || lowerPath.endsWith(".jpg") || lowerPath.endsWith(".jpeg") || lowerPath.endsWith(".webp")) {
                            imagePaths.push(filePath);
                            processNextFile();
                        } else {
                            var fileOut = "";
                            var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["cat", "' + filePath + '"] }', composer);
                            var parser = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
                            parser.read.connect(function(data) { fileOut += data + "\n"; });
                            p.stdout = parser;
                            p.exited.connect(function() {
                                if (fileOut.trim().length > 0) {
                                    var basename = filePath.substring(filePath.lastIndexOf("/") + 1);
                                    contextText += "<context source=\"file\" filename=\"" + basename + "\">\n" + fileOut.trim() + "\n</context>\n\n";
                                }
                                p.destroy();
                                processNextFile();
                            });
                            p.running = true;
                        }
                    }
                    processNextFile();
                } else {
                    nextStep();
                }
            },
            function() {
                composer.gatheringContext = false;
                var sources = [];
                if (composer.clipboardContext) sources.push("clipboard");
                if (composer.selectionContext) sources.push("selection");
                if (composer.screenContext) sources.push("screen");
                if (composer.attachedFiles && composer.attachedFiles.length > 0) sources.push("files");
                
                composer.removeClipboard();
                composer.removeSelection();
                composer.removeScreen();
                
                composer.promptSubmitted(userPrompt, contextText, sources.join(","), imagePaths);
            }
        ];

        function nextStep() {
            if (stepIndex < steps.length) {
                var step = steps[stepIndex];
                stepIndex++;
                step();
            }
        }
        nextStep();
    }

    height: activeContextCount > 0 ? 140 : 110
    radius: 20
    color: raisedColor
    border.width: 1
    border.color: composerInput.activeFocus
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.48)
        : Qt.rgba(mainText.r, mainText.g, mainText.b, 0.06)

    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Context chips row
    Flow {
        id: contextChips
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 12
        height: composer.activeContextCount > 0 ? 30 : 0
        spacing: 7
        visible: composer.activeContextCount > 0

        AssistantContextChip {
            visible: composer.clipboardContext
            theme: composer.theme
            icon: "content_paste"
            label: "Clipboard"
            onRemoved: composer.removeClipboard()
        }

        AssistantContextChip {
            visible: composer.selectionContext
            theme: composer.theme
            icon: "text_select_start"
            label: "Selected text"
            onRemoved: composer.removeSelection()
        }

        AssistantContextChip {
            visible: composer.screenContext
            theme: composer.theme
            icon: "screenshot_monitor"
            label: "Current screen"
            onRemoved: composer.removeScreen()
        }

        Repeater {
            model: composer.attachedFiles
            AssistantContextChip {
                theme: composer.theme
                icon: {
                    var p = modelData.toLowerCase();
                    if (p.endsWith(".png") || p.endsWith(".jpg") || p.endsWith(".jpeg") || p.endsWith(".webp")) return "image";
                    return "description";
                }
                label: modelData.substring(modelData.lastIndexOf("/") + 1)
                onRemoved: composer.removeAttachedFile(modelData)
            }
        }
    }

    TextArea {
        id: composerInput
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: composerActions.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: composer.activeContextCount > 0 ? 48 : 14
        padding: 0
        background: null
        placeholderText: composer.activeMode === "Ask" ? "Ask Reflection…" : composer.activeMode + " with Reflection…"
        placeholderTextColor: composer.mutedText
        color: composer.mainText
        selectionColor: composer.accent
        selectedTextColor: composer.theme ? composer.theme.bgBase : "#101014"
        font.family: composer.theme ? composer.theme.fontMain : "Inter"
        font.pixelSize: 15
        wrapMode: TextEdit.Wrap
        selectByMouse: true

        Keys.onReturnPressed: event => {
            if (!(event.modifiers & Qt.ShiftModifier) && !ConversationService.isGenerating) {
                composer.submitPrompt();
                event.accepted = true;
            }
        }
    }

    RowLayout {
        id: composerActions
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 8
        height: 40
        spacing: 6

        AssistantIconButton {
            theme: composer.theme
            icon: "add"
            toolTip: "Attach a file"
            onClicked: {
                State.GlobalStates.openFilePicker("Attach a File", "all", function(path) {
                    if (path && path.trim().length > 0) {
                        composer.fileAttached(path);
                    }
                });
            }
        }

        Text {
            Layout.fillWidth: true
            visible: !composer.compact
            text: "Enter to send  ·  Shift+Enter for a new line"
            horizontalAlignment: Text.AlignRight
            font.family: composer.theme ? composer.theme.fontMain : "Inter"
            font.pixelSize: 11
            color: composer.mutedText
        }

        Item {
            Layout.fillWidth: true
            visible: composer.compact
        }

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 13
            color: ConversationService.isGenerating
                ? Qt.rgba(composer.accent.r, composer.accent.g, composer.accent.b, 0.16)
                : (composerInput.text.trim().length > 0
                ? composer.accent
                : Qt.rgba(composer.subText.r, composer.subText.g, composer.subText.b, 0.10))

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: ConversationService.isGenerating ? "stop" : "arrow_upward"
                font.family: composer.theme ? composer.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 20
                color: ConversationService.isGenerating
                    ? composer.accent
                    : (composerInput.text.trim().length > 0
                    ? (composer.theme ? composer.theme.bgBase : "#101014")
                    : composer.mutedText)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (ConversationService.isGenerating)
                        ConversationService.stopGeneration();
                    else
                        composer.submitPrompt();
                }
            }
        }
    }
}
