
#!/usr/bin/perl
# Quickly install the latest Arch Linux ARM on micro-SD card (mmcblk0) for Raspberry Pi.
#
# Note: This script is intended to be run as root. Linux users only :P
# It is a quick hack and does not cover every possible scenario. 
# Sharing just for fun.
# You should verify everything it does before using it yourself. 
#
# Note: It will overwrite the device named "mmcblk0";
# DO NOT USE THIS SCRIPT IF YOUR SD CARD IS NOT CALLED "mmcblk0"!!
# IF I RAN THIS ON MY CHROMEBOOK IT WOULD WIPE THE FILESYSTEM!!
# BE CAREFUL!! DOUBLE-CHECK WITH `lsblk` BEFORE RUNNING THIS SCRIPT!!
#
# Note: This creates temporary 'root' and 'boot' folders for mounting.
# It will fail if directories with this name exist in the CWD.

use strict; use warnings;

# Check
my $device = "/dev/mmcblk0";
unless (-b $device) { die "Device '$device' could not be found." }
# TBD: Automated check for mmcblk0 safety?

# Partition
my $commands = qq{o\nn\np\n1\n\n+512M\nn\np\n2\n\n\nw\n};
open my $fdisk, "|-", "fdisk $device" or die "Unable to open fdisk: $!";
print $fdisk $commands;
close $fdisk or die "fdisk failed to close: $!";

my $boot = $device."p1"; my $root = $device."p2";
system("mkfs.vfat $boot") or die "mkfs failed to format $boot: $!"; 
system("mkfs.ext4 $root") or die "mkfs failed to format $root: $!"; 

mkdir "boot" or die "Error: Temporary 'boot' directory could not be created: $!";
mkdir "root" or die "Error: Temporary 'root' directory could not be created: $!";
system("mount $boot boot") or die "Failed to mount boot to $boot: $!";
system("mount $root root") or die "Failed to mount root to $root: $!";

# Install
my $image = "ArchLinuxARM-rpi-aarch64-latest.tar.gz";
unless (-e $image) { 
    system("wget http://os.archlinuxarm.org/os/$image") or die "Download failed: $!";
}
system "tar -xpf $image -C root" or die "Failed to extract image: $!";
system "sync" or die "Sync failed: $!";
system "mv ./root/boot/* boot" or die "Failed to move filesystem: $!";
system "perl -i -pe 's/mmcblk0/mmcblk1/g' root/etc/fstab" or die "Edit failed: $!";

# Cleanup
system "umount boot root" or die "Unmounting failed: $!";
system "rm -rf ./root ./boot" or die "Directory cleanup failed: $!";

print << 'FINISHED';
Arch ARM installation finished. 
Insert the memory card into your Raspberry Pi. Boot it up.
The default root password is 'root', and the default user/password is 'alarm'/'alarm'.
When you boot for the first time, remember to initialize pacman keys and get an update:
$ pacman-key --init
$ pacman-key --populate archlinuxarm
$ pacman -Syu
FINISHED
