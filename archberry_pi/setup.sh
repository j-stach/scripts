
#!/bin/bash
# Setup component to correct Arch installation for RaspberryPi.
# Intended to be run after booting into a new installation for the first time.
# Cleans up the mess left by the Frankensteinian installation process.

pacman-key --init
pacman-key --populate archlinuxarm
pacman -R linux-aarch64 uboot-raspberrypi
pacman -Syu --overwrite "/boot/*" linux-rpi

# TODO: Any other Arch setup steps that can be taken care of here?

reboot
