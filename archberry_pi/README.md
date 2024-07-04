
# archberry_pi
This is a script I use for quickly setting up Arch Linux for Raspberry Pi. <br>
`install.pl` partitions & formats a micro-SD card, 
then installs the latest version of Arch Linux ARM on it. <br>

**WARNING:** Script expects the memory card to be recognized as `/dev/mmcblk0`,
and will partition and overwrite the device with that name.
Double-check using `lsblk` to ensure the SD card is correctly-named. 
Do not use this script as-is if `mmcblk0` is assigned to a different device. 
(For example, running this script on my Chromebook would overwrite the filesystem!) <br>


## To use
1. Plug the micro-SD into your primary computer. 
2. Using `lsblk`, ensure that the device name is `/dev/mmcblk0`.
3. Run the install script with `sudo`: 
```
$ sudo wget -qO - "https://github.com/j-stach/scripts/archberry_pi/install.pl" | perl
```
4. Then pull the SD card and insert it into the Pi.
5. Connect the Pi to internet via ethernet cable, connect to power, then boot. 
The default Arch ARM user is 'alarm' (Arch Linux ARM) and the password is 'alarm'.
The default root password is 'root'.
6. The first time you log in, run the following commands as root:
```
# pacman-key --init
# pacman-key --populate archlinuxarm
# pacman -R linux-aarch64 uboot-raspberrypi
# pacman -Syu --overwrite "/boot/*" linux-rpi
# timedatectl set-timezone YourRegion/YourZone
# mkinitcpio -P
# reboot
```
7. Boot again, and open `/etc/locale.gen` in your preferred text editor. 
Uncomment your UTF zones, then run `# locale-gen`.
8. Configure the rest as needed. Remember to change your root password with `# passwd` 
and to set up a firewall if you are connecting to a network. Enjoy!

## Resources
There are nuances to the ARM version when it comes to packaging software, 
but otherwise it should behave the same as regular Arch Linux. <br>
- https://wiki.archlinux.org
- https://archlinuxarm.org/wiki







