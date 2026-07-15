import QtQuick
import "../../../../../core/services/system"
Item {
    Component.onCompleted: console.log("Success: " + AccountService.username)
}
