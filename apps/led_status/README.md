# LedStatus

Use the on-board LEDs to indicate wifi connection status. The connection status is not relying on VingageNet as that can get complicated and because of history with `nerves_networking` using a different source makes me feel more confident. It uses the IP addresses

The LEDs flash differently depending on WiFi status:

* Flashes rapidly if no WiFi address is allocated
* Flashes in a more measured way when the VingateNetWizard is up
* Does not flash when a WiFi address (other than the VintageNetWizard) is allocated
