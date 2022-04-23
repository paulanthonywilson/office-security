# Heartbeat

Kicks VintageNet if stuck in `lan_mode` too long, which seems to occasionally happen: tt looks like
it has a propery WiFi connection but does not.

Killing `VintageNet.RouteManager` seems to do the trick. (If the LAN is actually not connected to the
internet it will cause a disconnection.)

After even longer, tries a reboot.