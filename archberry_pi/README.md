
# archberry_pi
Scripts I use for quickly setting up Arch Linux for Raspberry Pi. <br>
`install.pl` partitions & formats a micro-SD card, 
then installs the latest version of Arch Linux ARM on it. <br>
`setup.pl` is to be run on the Raspberry Pi the first time it boots,
and will walk you through the remaining steps to set up the OS. <br>

**WARNING:** Script expects the memory card to be recognized as `/dev/mmcblk0`,
and will partition and overwrite the device with that name. <br>
Double-check using `lsblk` to ensure the SD card is correctly-named. 
Do not use this script as-is if `mmcblk0` is assigned to a different device. <br>
(For example, running this script on my Chromebook would overwrite the filesystem!) <br>


## To use
1. Plug the micro-SD into your primary computer. 
2. Using `lsblk`, ensure that the device name is `/dev/mmcblk0`.
3. Run the install script with `sudo`: TBD -- just use wget?
```
$ sudo wget -qO - <em>https://github.com/j-stach/scripts/archberry_pi/install.pl</em> | perl
```
4. Then pull the SD card and insert it into the Pi.
5. Connect the Pi to internet via ethernet cable, connect to power, then boot. 
The default Arch ARM user is 'alarm' (Arch Linux ARM) and the password is 'alarm'.
6. The first time you log in, run the setup script with sudo:
```
$ sudo wget -qO - <em>https://github.com/j-stach/scripts/archberry_pi/setup.sh</em> | bash
```
7. Configure Arch as needed! Enjoy!

## Resources
There are nuances to the ARM version when it comes to packaging software, 
but otherwise it should behave the same as regular Arch Linux. <br>
- https://wiki.archlinux.org
- https://archlinuxarm.org/wiki







