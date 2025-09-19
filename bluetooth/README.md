# Bluetooth Configuration Guide

This guide addresses two common issues when using an external Bluetooth keyboard on Fedora:

- Laptop does not wake from sleep via Bluetooth keyboard
- Unable to enter disk encryption key at boot

## Enable Wake from Sleep

Run the provided script to generate a `udev` rule that enables wake-from-sleep via Bluetooth. This only needs to be done once.

Attribution: `bt-wake.sh` was sourced from a Reddit thread; the script contains a header with the source URL. No explicit license was provided with the original script. If you are the original author and prefer a different license or attribution, please open an issue or a pull request.

## Enable Bluetooth for Disk Encryption at Boot

Copy `ble.conf` to `/etc/dracut.conf.d/` and regenerate the initramfs:

```
sudo dracut --force --regenerate-all
```

After rebooting, you should be able to enter your disk encryption password using the Bluetooth keyboard. Connection time may vary depending on the device.

