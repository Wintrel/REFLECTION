#!/usr/bin/env python3

import os
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_INTERFACE = "org.bluez.Agent1"
AGENT_PATH = "/quickshell/agent"
BUS_NAME = "org.bluez"
PIPE_PATH = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "bt_agent_in")

def set_trusted(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Device1", "Trusted", True)

class Agent(dbus.service.Object):
    def __init__(self, bus, path):
        super().__init__(bus, path)
        self.bus = bus
    
    def prompt_ui(self, prompt_type, device_path, data=""):
        mac = device_path.split("/")[-1].removeprefix("dev_").replace("_", ":")
        
        # Emit to QML Process stdout
        print(f"PROMPT|{prompt_type}|{mac}|{data}", flush=True)
        
        if not os.path.exists(PIPE_PATH):
            os.mkfifo(PIPE_PATH, 0o600)

        try:
            with open(PIPE_PATH, "r") as f:
                response = f.readline().strip()
                return response
        except Exception as e:
            print(f"ERROR|prompt_ui|{e}", flush=True)
            return "no"

    @dbus.service.method(AGENT_INTERFACE, in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        print(f"INFO|DisplayPinCode|{device}|{pincode}", flush=True)

    @dbus.service.method(AGENT_INTERFACE, in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        # passkey is an integer up to 6 digits
        pk = f"{passkey:06d}"
        resp = self.prompt_ui("PASSKEY", device, pk)
        if resp.lower() == "yes":
            set_trusted(self.bus, device)
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        resp = self.prompt_ui("AUTHORIZE", device)
        if resp.lower() == "yes":
            set_trusted(self.bus, device)
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        resp = self.prompt_ui("PIN", device)
        if resp:
            set_trusted(self.bus, device)
            return resp
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        resp = self.prompt_ui("ENTER_PASSKEY", device)
        try:
            passkey = dbus.UInt32(resp)
            set_trusted(self.bus, device)
            return passkey
        except Exception:
            raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="", out_signature="")
    def Cancel(self):
        print("INFO|Cancel", flush=True)

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    
    agent = Agent(bus, AGENT_PATH)
    
    manager = dbus.Interface(bus.get_object(BUS_NAME, "/org/bluez"), "org.bluez.AgentManager1")
    manager.RegisterAgent(AGENT_PATH, "KeyboardDisplay")
    manager.RequestDefaultAgent(AGENT_PATH)
    
    print("INFO|Agent Registered", flush=True)
    
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        pass
    finally:
        try:
            manager.UnregisterAgent(AGENT_PATH)
        except Exception:
            pass
        if os.path.exists(PIPE_PATH):
            os.unlink(PIPE_PATH)

if __name__ == '__main__':
    main()
