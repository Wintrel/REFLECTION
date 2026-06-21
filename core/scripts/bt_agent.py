#!/usr/bin/env python3

import sys
import os
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_INTERFACE = "org.bluez.Agent1"
AGENT_PATH = "/quickshell/agent"
BUS_NAME = "org.bluez"

def set_trusted(bus, device_path):
    props = dbus.Interface(bus.get_object("org.bluez", device_path), "org.freedesktop.DBus.Properties")
    props.Set("org.bluez.Device1", "Trusted", True)

class Agent(dbus.service.Object):
    def __init__(self, bus, path):
        super().__init__(bus, path)
        self.bus = bus
    
    def prompt_ui(self, prompt_type, device_path, data=""):
        mac = device_path.split("_")[1:]
        mac = ":".join(mac)
        
        # Emit to QML Process stdout
        print(f"PROMPT|{prompt_type}|{mac}|{data}", flush=True)
        
        pipe_path = "/tmp/bt_agent_in"
        if not os.path.exists(pipe_path):
            os.mkfifo(pipe_path)
            
        try:
            with open(pipe_path, "r") as f:
                response = f.readline().strip()
                return response
        except Exception:
            return "no"

    @dbus.service.method(AGENT_INTERFACE, in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        print(f"INFO|DisplayPinCode|{device}|{pincode}", flush=True)

    @dbus.service.method(AGENT_INTERFACE, in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        # passkey is an integer up to 6 digits
        pk = f"{passkey:06d}"
        set_trusted(self.bus, device)
        resp = self.prompt_ui("PASSKEY", device, pk)
        if resp.lower() == "yes":
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        set_trusted(self.bus, device)
        resp = self.prompt_ui("AUTHORIZE", device)
        if resp.lower() == "yes":
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        set_trusted(self.bus, device)
        resp = self.prompt_ui("PIN", device)
        if resp:
            return resp
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "User rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        set_trusted(self.bus, device)
        resp = self.prompt_ui("ENTER_PASSKEY", device)
        try:
            return dbus.UInt32(resp)
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

if __name__ == '__main__':
    main()
