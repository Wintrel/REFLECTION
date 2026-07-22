import os, json, subprocess, sys

STATE_FILE = os.path.expanduser("~/.config/quickshell/reflection/.battery_state.json")

def load_state():
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    return {"target_limit": 100, "is_oneshot": False}

def save_state(state):
    try:
        with open(STATE_FILE, 'w') as f:
            json.dump(state, f)
    except Exception as e:
        print(f"Error saving state: {e}", file=sys.stderr)

def read_sys(path):
    try:
        with open(path, 'r') as f:
            return f.read().strip()
    except Exception:
        return "0"

def get_battery_stats(no_asus=False):
    base = "/sys/class/power_supply/BAT0"
    if not os.path.exists(base):
        print(json.dumps({"error": "No BAT0"}))
        return
        
    capacity = int(read_sys(f"{base}/capacity"))
    status = read_sys(f"{base}/status")
    
    power_now = int(read_sys(f"{base}/power_now"))
    energy_full = int(read_sys(f"{base}/energy_full"))
    energy_full_design = int(read_sys(f"{base}/energy_full_design"))
    energy_now = int(read_sys(f"{base}/energy_now"))
    
    wattage = power_now / 1000000.0
    
    health = 100
    if energy_full_design > 0:
        health = int((energy_full / energy_full_design) * 100)
        
    time_remaining = ""
    if status == "Full":
        time_remaining = "Fully charged"
    elif status == "Not charging":
        time_remaining = "Limit reached"
    elif power_now > 0:
        if status == "Discharging":
            hours = energy_now / power_now
        else:
            hours = (energy_full - energy_now) / power_now
        h = int(hours)
        m = int((hours - h) * 60)
        if h > 0 or m > 0:
            time_remaining = f"{h}h {m}m"
        else:
            time_remaining = "Calculating..."
    else:
        time_remaining = ""
            
    # Get ASUS profile — skipped in no-asus mode, use state file cache instead
    profile = "Unknown"
    if not no_asus:
        try:
            profile_out = subprocess.check_output(['asusctl', 'profile', 'get'], timeout=3).decode().strip()
            for line in profile_out.split('\n'):
                if line.startswith('Active profile:'):
                    profile = line.split(':')[-1].strip()
                    break
        except Exception:
            pass
    else:
        # Use the last known profile from state so the UI doesn't reset to Unknown
        state_tmp = load_state()
        profile = state_tmp.get('last_profile', 'Balanced')
        
    # Get Battery Limit — skipped in no-asus mode
    actual_limit = 100
    if not no_asus:
        try:
            limit_out = subprocess.check_output(['asusctl', 'battery', 'info'], timeout=3).decode().strip()
            for line in limit_out.split('\n'):
                if line.startswith('Current battery charge limit:'):
                    actual_limit = int(line.split(':')[-1].strip().replace('%', ''))
                    break
        except Exception:
            pass
    else:
        state_tmp = load_state()
        actual_limit = state_tmp.get('target_limit', 100)
        
    state = load_state()
    is_oneshot = state.get("is_oneshot", False)
    target_limit = state.get("target_limit", 100)
    
    # Smart reversion of oneshot
    if is_oneshot:
        if status in ("Full", "Not charging", "Discharging"):
            is_oneshot = False
            state["is_oneshot"] = False
            save_state(state)
            
            # If we were full/not charging and asusctl doesn't auto-revert, we enforce it here:
            if status != "Discharging" and actual_limit == 100:
                try:
                    subprocess.check_call(['asusctl', 'battery', 'limit', str(target_limit)])
                except Exception:
                    pass

    # Fallback init: if state was 100 but actual limit is something else (and not oneshot), sync state
    if not is_oneshot and target_limit != actual_limit:
        # If user changed it via terminal directly, sync it back to our state.
        state["target_limit"] = actual_limit
        target_limit = actual_limit
        save_state(state)

    # Cache last known profile in state so no-asus mode can return it
    if not no_asus and profile != 'Unknown':
        state['last_profile'] = profile
        save_state(state)

    # Fetch peripherals via upower
    peripherals = []
    debug_log = []
    try:
        upower_out = subprocess.check_output(['upower', '-d'], timeout=5).decode()
        devices = []
        current_dev = {}
        for line in upower_out.split('\n'):
            if line.startswith('Device: '):
                if current_dev:
                    devices.append(current_dev)
                current_dev = {'path': line.split('Device: ')[1].strip()}
            else:
                stripped = line.strip()
                if ':' in stripped:
                    k, v = stripped.split(':', 1)
                    current_dev[k.strip()] = v.strip()
                # standalone section labels (e.g. 'mouse', 'battery') — ignore
        if current_dev:
            devices.append(current_dev)

        for dev in devices:
            if 'battery_BAT' in dev.get('path', ''): continue
            if 'line_power' in dev.get('path', ''): continue
            if 'DisplayDevice' in dev.get('path', ''): continue

            try:
                pct_raw = dev.get('percentage', '')
                model = dev.get('model', '').strip("'")
                if not pct_raw or not model:
                    continue
                # Strip trailing '%' and any extra text like '(0.75)'
                pct_clean = pct_raw.split()[0].strip('%')
                pct = int(pct_clean)

                icon_name = dev.get('icon-name', "'battery'").strip()
                if 'good' in icon_name:   icon_name = "battery_full"
                elif 'low' in icon_name:  icon_name = "battery_1_bar"
                elif 'empty' in icon_name: icon_name = "battery_alert"
                else:
                    path = dev.get('path', '')
                    icon_name = "mouse" if 'mouse' in path or 'hidpp' in path else "headphones"

                peripherals.append({'name': model, 'percentage': pct, 'icon': icon_name})
                debug_log.append(f"OK: {model} @ {pct}%")
            except Exception as dev_err:
                debug_log.append(f"SKIP {dev.get('path','?')}: {dev_err}")
    except Exception as e:
        debug_log.append(f"upower error: {e}")

    try:
        with open("/tmp/battery_poller_debug.log", "w") as f:
            f.write(json.dumps(peripherals) + "\n")
            f.write("\n".join(debug_log))
    except:
        pass

    print(json.dumps({
        "percentage": capacity,
        "status": status,
        "wattage": round(wattage, 1),
        "health": health,
        "timeRemaining": time_remaining,
        "energyNow": energy_now,
        "energyFull": energy_full,
        "asusProfile": profile,
        "batteryLimit": target_limit,
        "isOneshot": is_oneshot,
        "peripherals": peripherals
    }))

def set_limit(limit):
    try:
        subprocess.check_call(['asusctl', 'battery', 'limit', str(limit)])
        state = load_state()
        state['target_limit'] = int(limit)
        state['is_oneshot'] = False
        save_state(state)
        print(json.dumps({"success": True}))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

def get_profile_only():
    """Fetch only the asusctl profile and limit — used for on-demand sync when the panel opens."""
    profile = "Unknown"
    actual_limit = 100
    try:
        profile_out = subprocess.check_output(['asusctl', 'profile', 'get'], timeout=3).decode().strip()
        for line in profile_out.split('\n'):
            if line.startswith('Active profile:'):
                profile = line.split(':')[-1].strip()
                break
    except Exception:
        pass
    try:
        limit_out = subprocess.check_output(['asusctl', 'battery', 'info'], timeout=3).decode().strip()
        for line in limit_out.split('\n'):
            if line.startswith('Current battery charge limit:'):
                actual_limit = int(line.split(':')[-1].strip().replace('%', ''))
                break
    except Exception:
        pass
    # Cache it
    state = load_state()
    if profile != 'Unknown':
        state['last_profile'] = profile
        save_state(state)
    print(json.dumps({"asusProfile": profile, "batteryLimit": actual_limit}))

def set_oneshot(enable):
    enable_bool = str(enable).lower() == "true"
    state = load_state()
    try:
        if enable_bool:
            subprocess.check_call(['asusctl', 'battery', 'oneshot'])
            state['is_oneshot'] = True
        else:
            target = state.get('target_limit', 100)
            subprocess.check_call(['asusctl', 'battery', 'limit', str(target)])
            state['is_oneshot'] = False
        save_state(state)
        print(json.dumps({"success": True}))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "set_limit" and len(sys.argv) > 2:
            set_limit(sys.argv[2])
        elif cmd == "set_oneshot" and len(sys.argv) > 2:
            set_oneshot(sys.argv[2])
        elif cmd == "profile_only":
            get_profile_only()
        elif cmd == "no_asus":
            get_battery_stats(no_asus=True)
        else:
            get_battery_stats()
    else:
        get_battery_stats()
