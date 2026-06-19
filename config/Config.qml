import QtQuick

pragma Singleton

QtObject {
    property var options: {
        "time": {
            "format": "hh:mm",               // Used for general time (fallback: "hh:mm")
            "shortDateFormat": "dd/MM",      // Used for short dates (fallback: "dd/MM")
            "dateWithYearFormat": "dd/MM/yyyy", // Used for full dates (fallback: "dd/MM/yyyy")
            "dateFormat": "dddd, dd/MM"      // Used for long dates (fallback: "dddd, dd/MM")
        },
        "resources": {
            "updateInterval": 3000           // Timer interval in ms (fallback: 3000)
        }
    }
}
