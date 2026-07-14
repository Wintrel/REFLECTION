pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    property int percentage: 100
    property bool isCharging: false
    property bool isOnAC: false       // Plugged in but not actively charging (Full / Not charging)
    property string status: "Unknown" // Raw status: Charging, Discharging, Full, Not charging, Unknown
    
    // Detailed stats
    property real wattage: 0
    property int health: 100
    property string timeRemaining: ""
    
    // Smoothed values for UI display (EMA-averaged)
    property real smoothWattage: 0
    property string smoothTimeRemaining: ""
    property string smoothTimeLabel: ""
    
    // Raw energy values for smooth time computation
    property real _energyNow: 0
    property real _energyFull: 0
    property bool _hasInitSmooth: false
    
    // ASUS ROG specifics
    property string asusProfile: "Unknown"
    property int batteryLimit: 100
    property bool isOneshotCharging: false  // True when a one-time full charge is in progress
    
    property bool _hasInitPercent: false
    property bool _hasInitCharge: false
    property int _lastNotifiedBattery: 100
    
    // EMA smoothing helper (alpha = 0.3 → ~3-4 polls to converge)
    function _ema(current, previous, alpha) {
        return alpha * current + (1 - alpha) * previous;
    }
    
    // Compute time remaining string from energy values and smoothed wattage
    function _updateSmoothTime(status, energyNow, energyFull, watts, limit, isOneshot) {
        if (status === "Full") {
            root.smoothTimeRemaining = "Fully charged";
            root.smoothTimeLabel = "";
            return;
        }
        if (status === "Not charging") {
            root.smoothTimeRemaining = "Limit reached";
            root.smoothTimeLabel = "";
            return;
        }
        if (watts <= 0.1) {
            root.smoothTimeRemaining = "";
            root.smoothTimeLabel = "";
            return;
        }
        
        var powerMicro = watts * 1000000;
        var hours;
        var label = "";
        
        if (status === "Discharging") {
            hours = energyNow / powerMicro;
            label = "remaining";
        } else {
            var targetPercent = isOneshot ? 100 : limit;
            var targetEnergy = energyFull * (targetPercent / 100.0);
            
            if (targetEnergy <= energyNow) {
                root.smoothTimeRemaining = targetPercent === 100 ? "Fully charged" : "Limit reached";
                root.smoothTimeLabel = "";
                return;
            }
            hours = (targetEnergy - energyNow) / powerMicro;
            label = targetPercent === 100 ? "until full" : "until limit";
        }
        
        if (hours < 0) {
            root.smoothTimeRemaining = "";
            root.smoothTimeLabel = "";
            return;
        }
        
        var h = Math.floor(hours);
        var m = Math.floor((hours - h) * 60);
        
        if (h > 0 || m > 0) {
            root.smoothTimeRemaining = h + "h " + m + "m";
            root.smoothTimeLabel = label;
        } else {
            root.smoothTimeRemaining = "Calculating...";
            root.smoothTimeLabel = "";
        }
    }
    
    property Process statsProcess: Process {
        command: ["python", Quickshell.env("HOME") + "/.config/quickshell/reflection/core/services/system/battery_poller.py", "no_asus"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var stats = JSON.parse(data.trim());
                    if (stats.error) return;
                    
                    // Basic stats
                    var val = stats.percentage;
                    if (root._hasInitPercent && val <= 20 && root._lastNotifiedBattery > 20) {
                        OsdService.showOsd(2, 2, "battery_alert", "Battery 20% Remaining", "#E5C07B");
                    } else if (root._hasInitPercent && val <= 10 && root._lastNotifiedBattery > 10) {
                        OsdService.showOsd(2, 3, "battery_alert", "⚠ Battery Critical – 10% Remaining", "#E06C75");
                    }
                    root._lastNotifiedBattery = val;
                    root.percentage = val;
                    root._hasInitPercent = true;
                    
                    // Determine power state from raw status
                    var rawStatus = stats.status;
                    root.status = rawStatus;
                    
                    var newCharging = (rawStatus === "Charging");
                    var newOnAC = (rawStatus === "Full" || rawStatus === "Not charging");
                    var wasPluggedIn = root.isCharging || root.isOnAC;
                    var nowPluggedIn = newCharging || newOnAC;
                    
                    if (wasPluggedIn !== nowPluggedIn) {
                        if (root._hasInitCharge) {
                            if (nowPluggedIn) {
                                var icon = newCharging ? "battery_charging_full" : "power";
                                var text = newCharging ? "Charging" : "Connected to AC";
                                OsdService.showOsd(2, 1, icon, text, "");
                            } else {
                                OsdService.showOsd(2, 1, "battery_horiz_050", "Unplugged", "");
                            }
                        }
                    } else if (root.isCharging && !newCharging && newOnAC && root._hasInitCharge) {
                        // Was charging, now full/limit reached
                        var doneIcon = rawStatus === "Full" ? "battery_full" : "battery_saver";
                        var doneText = rawStatus === "Full" ? "Fully Charged" : "Charge Limit Reached";
                        OsdService.showOsd(2, 1, doneIcon, doneText, "");
                    }
                    
                    root.isCharging = newCharging;
                    root.isOnAC = newOnAC;
                    root._hasInitCharge = true;
                    
                    // Raw stats
                    root.wattage = stats.wattage;
                    root.health = stats.health;
                    root.timeRemaining = stats.timeRemaining;
                    root._energyNow = stats.energyNow || 0;
                    root._energyFull = stats.energyFull || 0;
                    
                    // Smoothed values (EMA with alpha 0.3)
                    if (!root._hasInitSmooth) {
                        root.smoothWattage = stats.wattage;
                        root._hasInitSmooth = true;
                    } else {
                        root.smoothWattage = root._ema(stats.wattage, root.smoothWattage, 0.3);
                    }
                    root._updateSmoothTime(
                        rawStatus, root._energyNow, root._energyFull, root.smoothWattage, stats.batteryLimit, root.isOneshotCharging
                    );
                    
                    root.asusProfile = stats.asusProfile;
                    root.batteryLimit = stats.batteryLimit;
                    
                    var newOneshot = stats.isOneshot !== undefined ? stats.isOneshot : root.isOneshotCharging;
                    // Auto-revert oneshot notification if it completed
                    if (root.isOneshotCharging && !newOneshot && root._hasInitCharge) {
                        if (rawStatus === "Full" || rawStatus === "Not charging") {
                            OsdService.showOsd(2, 1, "battery_full", "Full Charge Complete", "");
                        }
                    }
                    root.isOneshotCharging = newOneshot;
                } catch (e) {
                    console.log("Error parsing battery stats: " + e);
                }
            }
        }
    }
    
    property Process setProfileProcess: Process {}
    function setAsusProfile(profile) {
        setProfileProcess.command = ["asusctl", "profile", "set", profile];
        setProfileProcess.running = true;
        root.asusProfile = profile; // Optimistic update
        // Confirm the change landed after a short delay
        profileRefreshTimer.restart();
    }
    
    // Dedicated process for fetching only profile + limit on demand
    property Process profileProcess: Process {
        command: ["python", Quickshell.env("HOME") + "/.config/quickshell/reflection/core/services/system/battery_poller.py", "profile_only"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var r = JSON.parse(data.trim());
                    if (r.asusProfile) root.asusProfile = r.asusProfile;
                    if (r.batteryLimit !== undefined) root.batteryLimit = r.batteryLimit;
                } catch (e) {}
            }
        }
    }
    function refreshProfile() {
        root.profileProcess.running = false;
        root.profileProcess.running = true;
    }
    
    // Short delay after setAsusProfile so asusctl has time to apply before we read back
    property Timer profileRefreshTimer: Timer {
        interval: 800
        repeat: false
        onTriggered: root.refreshProfile()
    }
    
    // Track whether the battery panel is open — refresh profile immediately on open
    property bool panelOpen: false
    onPanelOpenChanged: {
        if (root.panelOpen) root.refreshProfile();
    }

    property Process setLimitProcess: Process {}
    function setChargeLimit(limit) {
        setLimitProcess.command = ["python", Quickshell.env("HOME") + "/.config/quickshell/reflection/core/services/system/battery_poller.py", "set_limit", limit.toString()];
        setLimitProcess.running = true;
        root.batteryLimit = limit; // Optimistic update
    }
    
    // One-time full charge via asusctl battery oneshot
    property Process oneshotProcess: Process {}
    function chargeFullOnce() {
        oneshotProcess.command = ["python", Quickshell.env("HOME") + "/.config/quickshell/reflection/core/services/system/battery_poller.py", "set_oneshot", "true"];
        oneshotProcess.running = true;
        root.isOneshotCharging = true;
        OsdService.showOsd(2, 1, "battery_charging_full", "One-Shot Charge Activated", "");
    }
    
    // Cancel oneshot by resetting to the current limit
    function cancelOneshot() {
        oneshotProcess.command = ["python", Quickshell.env("HOME") + "/.config/quickshell/reflection/core/services/system/battery_poller.py", "set_oneshot", "false"];
        oneshotProcess.running = true;
        root.isOneshotCharging = false;
        OsdService.showOsd(2, 1, "battery_saver", "One-shot cancelled", "");
    }
    
    property Timer poller: Timer {
        running: true
        repeat: true
        interval: 10000 // every 10 seconds
        onTriggered: {
            root.statsProcess.running = true;
        }
    }
    
    Component.onCompleted: {
        root.statsProcess.running = true;
    }
}
