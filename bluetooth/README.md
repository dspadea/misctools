# Bluetooth Tweaks

I was having two problems on my Fedora laptop when using an external bluetooth keyboard:

* My laptop would not wake from sleep when I pressed a key
* I couldn't enter the disk encryption key when the laptop booted

Both of these are pretty annoying. 

## Wake from Sleep

Fortunately, a bit of googling about found the script included here to enable wake-from-sleep
with bluetooth. It's basically exactly as I found it on a Reddit post. It generates a `udev` rule, 
so you only need to run it once and it should fix it going forward. 

Here's where I found it: https://www.reddit.com/r/Ubuntu/comments/169d24v/comment/mivozfo/

## Bluetooth in Initramfs

As for the disk encryption, just drop the ble.conf file into `/etc/dracut.conf.d/` and run:

```
sudo dracut --force --regenerate-all
```

Once you reboot, you should be able to enter your disk encryption password with your keyboard. 

Depending on the keyboard, you might need to press a key first and/or give it a second to connect,
but, at least for me, it works great.

