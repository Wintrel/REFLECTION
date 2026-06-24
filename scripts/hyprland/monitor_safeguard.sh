#!/usr/bin/env bash

# monitor_safeguard.sh
# Daemon that listens to Hyprland's socket2 and resets broken Nvidia monitors on hotplug

# Wait for Hyprland to start and HYPRLAND_INSTANCE_SIGNATURE to be available
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 1
done

SOCKET2="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

if [ ! -S "$SOCKET2" ]; then
    # Fallback if XDG_RUNTIME_DIR isn't perfectly resolving
    SOCKET2="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
fi

check_monitors() {
    # Extract broken monitor names using jq
    # Criteria: model is 0x0000, description contains 0x0000, or width is extremely low like 640
    broken_monitors=$(hyprctl monitors -j | jq -r '.[] | select((.description | contains("0x0000")) or (.model == "0x0000") or (.width <= 640)) | .name')
    
    for monitor in $broken_monitors; do
        if [ -n "$monitor" ] && [ "$monitor" != "null" ]; then
            echo "[Monitor Safeguard] Detected broken monitor: $monitor. Initiating reset loop."
            
            # Nvidia cache reset loop: Disable output, wait, re-enable
            hyprctl keyword monitor "$monitor, disable"
            sleep 1.5
            hyprctl keyword monitor "$monitor, preferred, auto, 1"
            
            # Wait a bit before allowing another check to prevent aggressive looping
            sleep 3
        fi
    done
}

# Initial check on startup
check_monitors

# Listen for monitor hotplug events
socat -U - UNIX-CONNECT:"$SOCKET2" | while read -r line; do
    if [[ "$line" == "monitoradded>>"* ]]; then
        # Wait a moment for the kernel DRM/KMS to settle before checking the Hyprland state
        sleep 1
        check_monitors
    fi
done
