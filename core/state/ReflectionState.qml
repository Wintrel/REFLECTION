pragma Singleton
import QtQuick

QtObject {
    property bool isOpen: false
    property string searchQuery: ""

    function toggle() {
        isOpen = !isOpen;
    }

    function close() {
        isOpen = false;
        searchQuery = "";
    }
}
