pragma Singleton

import QtQuick

Item {
    id: root

    property bool isOpen: false
    property string searchQuery: ""

    function open() {
        root.searchQuery = "";
        root.isOpen = true;
    }

    function close() {
        root.isOpen = false;
        root.searchQuery = "";
    }
    
    function toggle() {
        if (root.isOpen) root.close();
        else root.open();
    }
}
