pragma Singleton
import QtQuick

QtObject {
    id: root
    
    // mode: 0=Volume, 1=Brightness, 2=Text
    // priority: 1=Informational (2s), 2=Attention (4s), 3=Critical (8s)
    signal osdRequested(int mode, int priority, string icon, string text, string color)
    
    function showOsd(mode, priority, icon, text, color) {
        root.osdRequested(mode, priority, icon, text, color);
    }
}
