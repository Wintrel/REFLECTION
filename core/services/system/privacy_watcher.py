#!/usr/bin/env python3
import os
import sys
import subprocess
import json
import time
import select
import glob

def get_monitor_sources():
    try:
        res = subprocess.run(["pactl", "list", "sources", "short"], capture_output=True, text=True, timeout=1)
        monitor_ids = set()
        for line in res.stdout.strip().split("\n"):
            parts = line.split()
            if len(parts) >= 2:
                src_id, src_name = parts[0], parts[1]
                if "monitor" in src_name.lower():
                    monitor_ids.add(src_id)
        return monitor_ids
    except Exception:
        return set()

def check_mic_active():
    try:
        monitor_ids = get_monitor_sources()
        so_res = subprocess.run(["pactl", "list", "source-outputs"], capture_output=True, text=True, timeout=1)
        if not so_res.stdout.strip():
            return False

        blocks = so_res.stdout.split("Source Output #")
        for b in blocks:
            if not b.strip():
                continue
            
            src_id = None
            app_name = ""
            media_name = ""
            
            for line in b.split("\n"):
                l = line.strip()
                if l.startswith("Source:"):
                    src_id = l.split(":", 1)[1].strip()
                elif "application.name =" in l:
                    app_name = l.split("=", 1)[1].strip().strip('"').lower()
                elif "media.name =" in l:
                    media_name = l.split("=", 1)[1].strip().strip('"').lower()

            # Ignore monitor streams (audio visualizers, CAVA, speaker loopback, peak meters)
            if src_id in monitor_ids:
                continue
            if any(v in app_name for v in ["cava", "visualizer", "peak detect"]):
                continue
            if any(v in media_name for v in ["peak detect", "playback monitor"]):
                continue

            # Real microphone recording stream active
            return True

        return False
    except Exception:
        return False

def check_camera_active():
    try:
        video_devs = glob.glob("/dev/video*")
        if not video_devs:
            return False
        
        # Check active processes holding video dev fds
        res = subprocess.run(["fuser", "-v"] + video_devs, capture_output=True, text=True, timeout=1)
        combined = (res.stdout + "\n" + res.stderr).lower()
        
        for line in combined.split("\n"):
            line = line.strip()
            if not line or "/dev/video" in line or "command" in line:
                continue
            parts = line.split()
            if len(parts) >= 3:
                cmd = parts[2]
                if cmd not in ["wireplumber", "pipewire", "pipewire-media-session", "systemd"]:
                    return True
        return False
    except Exception:
        return False

def check_screen_recording():
    try:
        res = subprocess.run(["pgrep", "-x", "wf-recorder|wl-screenrec|obs"], capture_output=True, text=True, timeout=1)
        return bool(res.stdout.strip())
    except Exception:
        return False

def get_state():
    return {
        "mic": check_mic_active(),
        "cam": check_camera_active(),
        "screen": check_screen_recording()
    }

def main():
    last_state = None

    curr_state = get_state()
    print(json.dumps(curr_state), flush=True)
    last_state = curr_state

    try:
        pactl_proc = subprocess.Popen(
            ["pactl", "subscribe"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
    except Exception:
        pactl_proc = None

    poll_obj = select.poll()
    if pactl_proc and pactl_proc.stdout:
        poll_obj.register(pactl_proc.stdout, select.POLLIN)

    while True:
        try:
            events = poll_obj.poll(2000)
            if events:
                for fd, event in events:
                    try:
                        pactl_proc.stdout.readline()
                    except Exception:
                        pass

            new_state = get_state()
            if new_state != last_state:
                print(json.dumps(new_state), flush=True)
                last_state = new_state

        except KeyboardInterrupt:
            break
        except Exception as e:
            time.sleep(1)

    if pactl_proc:
        pactl_proc.terminate()

if __name__ == "__main__":
    main()
