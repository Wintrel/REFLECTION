#!/usr/bin/env bash

# monitor_safeguard.sh
# Daemon that listens to Hyprland's socket2 and DBus sleep events to reset broken Nvidia monitors

# Wait for Hyprland to start and HYPRLAND_INSTANCE_SIGNATURE to be available
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 1
done

SOCKET2="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
if [ ! -S "$SOCKET2" ]; then
    SOCKET2="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
fi

check_monitors() {
    # Extract broken monitor names using jq
    broken_monitors=$(hyprctl monitors -j | jq -r '.[] | select((.description | contains("0x0000")) or (.model == "0x0000") or (.width <= 640)) | .name')
    
    for monitor in $broken_monitors; do
        if [ -n "$monitor" ] && [ "$monitor" != "null" ]; then
            echo "[Monitor Safeguard] Detected broken monitor: $monitor. Initiating reset loop."
            
            # Nvidia cache reset loop: Disable output, wait, re-enable
            hyprctl eval "hl.monitor({ output = '$monitor', disabled = true })"
            sleep 1.5
            
            # Retrieve the correct monitor configuration from hyprmon.lua
            MONITOR_CONF=$(grep "output = \"$monitor\"" "$HOME/.config/hypr/hyprmon.lua" 2>/dev/null || true)
            
            if [ -n "$MONITOR_CONF" ]; then
                hyprctl eval "$MONITOR_CONF"
            else
                hyprctl eval "hl.monitor({ output = '$monitor', mode = 'preferred', position = 'auto', scale = 1 })"
            fi
            
            sleep 3
        fi
    done
}

# --- FUNCTION 1: Listen for System Wake ---
listen_sleep_events() {
    dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" | while read -r line; do
        if [[ "$line" == *"boolean false"* ]]; then
            echo "[Monitor Safeguard] System woke from sleep. Waiting for displays to initialize..."
            sleep 3
            check_monitors
            sleep 5
            check_monitors
        fi
    done
}

# --- FUNCTION 2: Listen for Hotplugs ---
listen_hotplug_events() {
    python3 -c "
import socket, sys
s=socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(sys.argv[1])
for line in s.makefile('r', buffering=1): print(line.strip(), flush=True)
" "$SOCKET2" | while read -r line; do
        if [[ "$line" == "monitoradded>>"* ]]; then
            sleep 1
            check_monitors
        fi
    done
}

# Run the initial check on script startup
check_monitors

# Fire up both listeners as background daemons
listen_sleep_events &
listen_hotplug_events &

# Keep the main script alive tracking the background processes
wait