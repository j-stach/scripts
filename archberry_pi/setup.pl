
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

use strict; use warnings;

my $device = "/dev/mmcblk0";
my $boot = $device."p1";
my $root = $device."p2";
my $mount = "/mnt/sd";
my $temp = "/tmp/pi";
my $image = "ArchLinuxARM-rpi-aarch64-latest.tar.gz";
my $url = "http://os.archlinuxarm.org/os/$image";
my $color = "\e[34m";
my $reset = "\e[0m";

# Setup
unless (-b $device) { die "Device '$device' could not be found." }
# TBD: Automated check for mmcblk0 safety?
mkdir $temp or die "Temporary directory could not be created: $!";
system("wget -P $temp $url") == 0 or die "Download failed: $!";

# Partition
print "$color>>> Partitioning disk...\n$reset";
my $commands = <<'END';
,256M,0c,
,,,
END
system("sfdisk --quiet --wipe always $device $commands") == 0
    or die "Partitioning failed: $!";

# Format
print "$color>>> Formatting partitions...\n$reset";
system("mkfs.vfat -F 32 $boot") == 0
    or die "mkfs failed to format $boot: $!";
my $options = "-E lazy_itable_init=0,lazy_journal_init=0";
system("mkfs.ext4 $options -F $root") == 0
    or die "mkfs failed to format $root: $!";

mkdir $mount or die "Mount directory could not be created: $!";
system("mount $root $mount") == 0 or die "Failed to mount: $!";
mkdir "$mount/boot" or die "Boot directory could not be created: $!";
system("mount $boot $root/boot") == 0 or die "Failed to mount: $!";

# Install
print "$color>>> Installing Arch Linux ARM...$reset\nThis may take a few minutes...\n";
system("tar -xpf $temp/$image -C $mount") == 0
    or die "Failed to extract image: $!";
system("sync") == 0 or die "Sync failed: $!";

# TODO
system("mv ./root/boot/* boot") == 0 or die "Failed to move filesystem: $!";
system("perl -i -pe 's/mmcblk0/mmcblk1/g' root/etc/fstab") == 0
    or die "Failed to edit fstab: $!";

# Fix


# Cleanup
print "$color>>> Cleaning up temporary directories...\n$reset";
system("umount boot root") == 0 or die "Unmounting failed: $!";
system("rm -rf ./root ./boot") == 0 or die "Directory cleanup failed: $!";
# TODO: Clean up the Arch tarball too? Probably should?

print "$color>>> Success!\n$reset";

print << 'FINISHED';
Arch ARM installation finished. 
Insert the memory card into your Raspberry Pi. Connect ethernet to network. Boot it up.
The default root password is 'root', and the default user/password is 'alarm'/'alarm'.
When you boot for the first time, remember to initialize pacman keys and get an update:
$ pacman-key --init
$ pacman-key --populate archlinuxarm
$ pacman -Syu
FINISHED
