#!/usr/bin/env bash

# As found here: https://www.reddit.com/r/Ubuntu/comments/169d24v/comment/mivozfo/

# This script creates a udev rule for each bluetooth controller to enable wakeup from suspend.
# (You can delete all the lines starting with # if you want, they are just comments FYI.)
# Find and loop over all bluetooth files within /sys/bus/usb/devices.
#   (There is only one Bluetooth controller on my system, but this should work if you have more than one.)
#   Get the directory path for each bluetooth device.
#   On my Framework 16, this returns: /sys/bus/usb/devices/1-5:1.0
#   `find -L` follows symlinks; `-maxdepth 2` prevents infinite recursion; `xargs dirname` gets the directory name of the bluetooth file
for path in $(find -L /sys/bus/usb/devices -maxdepth 2 -name bluetooth | xargs dirname); do
    # Get the "parent" USB controller by trimming the :1.0 (or :whatever) from the path.
    path="${path%:*}"
    # On my Framework 16, I'm using the Intel AX210:
    # idVendor 8087 = Intel
    # idProduct 0032 = AX210 Bluetooth
    # I found a lookup tool at https://the-sz.com/products/usbid/
    # But this solution should be general for any Bluetooth controller, so let's get the `idVendor` and `idProduct` for the controller dynamically:
    idVendor=$(cat "$path/idVendor")
    idProduct=$(cat "$path/idProduct")
    # Create a udev rule to enable wakeup on the controller on every reboot.
    # The `/sys%p/power/wakeup` substitutes the path dynamically at run time because the sys path might change.
    # (`/sys%p`... is correct, because `%p` starts with a /.)
    echo "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"$idVendor\", ATTRS{idProduct}==\"$idProduct\", RUN+=\"/bin/sh -c 'echo enabled > /sys%p/power/wakeup'\"" \
        | sudo tee /etc/udev/rules.d/10-wakeup-$idVendor-$idProduct.rules
done
# Apply the rule(s) immediately.
sudo udevadm trigger
