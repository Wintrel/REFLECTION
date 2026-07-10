import os, json, subprocess

def read_sys(path):
    try:
        with open(path, 'r') as f:
            return f.read().strip()
    except Exception:
        return "0"

def get_battery_stats():
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
            
    # Get ASUS profile
    profile = "Unknown"
    try:
        profile_out = subprocess.check_output(['asusctl', 'profile', 'get']).decode().strip()
        for line in profile_out.split('\n'):
            if line.startswith('Active profile:'):
                profile = line.split(':')[-1].strip()
                break
    except Exception:
        pass
        
    # Get Battery Limit
    limit = 100
    try:
        limit_out = subprocess.check_output(['asusctl', 'battery', 'info']).decode().strip()
        for line in limit_out.split('\n'):
            if line.startswith('Current battery charge limit:'):
                limit = int(line.split(':')[-1].strip().replace('%', ''))
                break
    except Exception:
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
        "batteryLimit": limit
    }))

if __name__ == "__main__":
    get_battery_stats()
