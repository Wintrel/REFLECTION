#!/bin/bash

# Script to transition swww wallpapers to a darkened monochrome for Ambient Idle

STATE=$1
CACHE_DIR="/tmp/quickshell_reflection_wallpaper"
mkdir -p "$CACHE_DIR"

if command -v hyprctl &> /dev/null; then
    # Get monitor list as JSON and process per-monitor workspace switching
    MONITORS_JSON=$(hyprctl monitors -j 2>/dev/null)

    if [ "$STATE" == "idle" ]; then
        # Save each monitor's current workspace and switch to a dedicated idle workspace
        # We use high workspace IDs (90+) to avoid colliding with normal workspaces
        echo "$MONITORS_JSON" | python3 -c "
import sys, json, subprocess, os
monitors = json.load(sys.stdin)
cache = '$CACHE_DIR'
for i, m in enumerate(monitors):
    name = m['name']
    ws_id = m['activeWorkspace']['id']
    # Save the current workspace so we can restore on wake
    with open(os.path.join(cache, name + '_workspace'), 'w') as f:
        f.write(str(ws_id))
    # Switch this monitor to its dedicated idle workspace
    idle_ws = 90 + i
    subprocess.run(['hyprctl', 'dispatch', f'hl.dsp.focus({{monitor=\"{name}\"}})'], capture_output=True)
    subprocess.run(['hyprctl', 'dispatch', f'hl.dsp.focus({{workspace=\"{idle_ws}\"}})'], capture_output=True)
"
    else
        # Wake: restore each monitor to its saved workspace
        echo "$MONITORS_JSON" | python3 -c "
import sys, json, subprocess, os
monitors = json.load(sys.stdin)
cache = '$CACHE_DIR'
for m in monitors:
    name = m['name']
    ws_file = os.path.join(cache, name + '_workspace')
    if os.path.exists(ws_file):
        ws_id = open(ws_file).read().strip()
        subprocess.run(['hyprctl', 'dispatch', f'hl.dsp.focus({{monitor=\"{name}\"}})'], capture_output=True)
        subprocess.run(['hyprctl', 'dispatch', f'hl.dsp.focus({{workspace=\"{ws_id}\"}})'], capture_output=True)
"
    fi
fi

if [ "$STATE" == "idle" ]; then
    # Query current wallpapers
    # Ignore errors if awww is not running yet
    awww query 2>/dev/null | while read -r line; do
        MONITOR=$(echo "$line" | awk -F':' '{print $2}' | tr -d ' ')
        IMG_PATH=$(echo "$line" | sed 's/.*image: //')
        
        if [ -n "$IMG_PATH" ] && [ -f "$IMG_PATH" ]; then
            # Do not overwrite the original path if we are already displaying a monochrome wallpaper
            if [[ "$IMG_PATH" != "$CACHE_DIR"* ]]; then
                echo "$IMG_PATH" > "$CACHE_DIR/${MONITOR}_original"
            fi
            
            # Read the original path back to base the monochrome image on it
            if [ -f "$CACHE_DIR/${MONITOR}_original" ]; then
                ORIG_IMG_PATH=$(cat "$CACHE_DIR/${MONITOR}_original")
            else
                ORIG_IMG_PATH="$IMG_PATH"
            fi
            
            # Generate monochrome image based on the original path
            IMG_HASH=$(echo -n "$ORIG_IMG_PATH" | md5sum | awk '{print $1}')
            MONO_IMG="$CACHE_DIR/${IMG_HASH}_mono.jpg"
            
            if [ ! -f "$MONO_IMG" ]; then
                # Use ImageMagick to convert to grayscale and slightly darken it
                # -modulate Brightness,Saturation,Hue (85% brightness, 0% saturation)
                if command -v magick &> /dev/null; then
                    magick "$ORIG_IMG_PATH" -modulate 85,0,100 "$MONO_IMG"
                elif command -v convert &> /dev/null; then
                    convert "$ORIG_IMG_PATH" -modulate 85,0,100 "$MONO_IMG"
                else
                    echo "ImageMagick not installed. Cannot create monochrome wallpaper."
                    exit 1
                fi
            fi
            
            # Transition to monochrome using a slow fade (1.5 seconds)
            awww img "$MONO_IMG" -o "$MONITOR" --transition-type fade --transition-duration 1.5
        fi
    done

elif [ "$STATE" == "wake" ]; then
    # Restore original wallpapers
    for cache_file in "$CACHE_DIR"/*_original; do
        if [ -f "$cache_file" ]; then
            MONITOR=$(basename "$cache_file" | sed 's/_original//')
            IMG_PATH=$(cat "$cache_file")
            
            if [ -f "$IMG_PATH" ]; then
                # Quick fade back to normal (0.5 seconds)
                awww img "$IMG_PATH" -o "$MONITOR" --transition-type fade --transition-duration 0.5
            fi
        fi
    done
fi
