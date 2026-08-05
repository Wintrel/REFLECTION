pragma Singleton
import QtQuick

QtObject {
    property bool isOpen: false
    property string searchQuery: ""
    property bool assistantMode: false

    function toggle() {
        isOpen = !isOpen;
    }

    function close() {
        isOpen = false;
        searchQuery = "";
        assistantMode = false;
    }

    function toggleAssistantMode() {
        assistantMode = !assistantMode;
        searchQuery = "";
    }
}
