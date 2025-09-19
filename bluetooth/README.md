# Bluetooth Configuration Guide

This guide addresses two common issues when using an external Bluetooth keyboard on Fedora:

- Laptop does not wake from sleep via Bluetooth keyboard
- Unable to enter disk encryption key at boot

## Enable Wake from Sleep

Run the provided script to generate a `udev` rule that enables wake-from-sleep via Bluetooth. This only needs to be done once.

Reference: [Reddit post](https://www.reddit.com/r/Ubuntu/comments/169d24v/comment/mivozfo/)

## Enable Bluetooth for Disk Encryption at Boot

Copy `ble.conf` to `/etc/dracut.conf.d/` and regenerate the initramfs:

```
sudo dracut --force --regenerate-all
```

After rebooting, you should be able to enter your disk encryption password using the Bluetooth keyboard. Connection time may vary depending on the device.

