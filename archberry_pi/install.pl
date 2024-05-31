
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
use File::Path qw{make_path remove_tree};

my $DEVICE = "/dev/mmcblk0";
my $BOOT_PARTITION = $DEVICE."p1";
my $ROOT_PARTITION = $DEVICE."p2";
my $MOUNT_DIR = "/mnt/sd";
my $TEMP_DIR = "/tmp/pi";
my $IMAGE_TAR = "ArchLinuxARM-rpi-aarch64-latest.tar.gz";
my $IMAGE_URL = "http://os.archlinuxarm.org/os/$IMAGE_TAR";
my $KERNEL_DEPOT = $TEMP_DIR."/linux-rpi";
my $KERNEL_TAR = "linux-rpi-16k-6.6.31-2-aarch64.pkg.tar.xz";
my $KERNEL_URL = "http://mirror.archlinuxarm.org/aarch64/core/$KERNEL_TAR";
my $COLOR_BLUE = "\e[34m";
my $RESET_COLOR = "\e[0m";

sub main {
# TODO Options for "no-clean" for repeat, instead of redownload
# TODO Option for redownload
# TODO Option for quiet/verbose
# TODO Help
&check_device;

# TODO check for /tmp/pi
&setup_temp_dir;

print "$COLOR_BLUE>>> Downloading files...$RESET_COLOR
This may take a few minutes...\n";
&download_images;

print "$COLOR_BLUE>>> Partitioning disk...\n$RESET_COLOR";
&partition_device;

print "$COLOR_BLUE>>> Formatting partitions...\n$RESET_COLOR";
&format_partitions;
&mount_partitions;

print "$COLOR_BLUE>>> Installing Arch Linux ARM...$RESET_COLOR
This may take a few minutes...\n";
&install_arch_linux;

# TODO Print green
# TODO Space out print statement lines
print "$COLOR_BLUE>>> Syncing...$RESET_COLOR
This may take a few minutes...\n";
# TODO Separate cleanup and sync, so that it doesn't have to download every time?
&cleanup;

print "$COLOR_BLUE>>> Success!\n$RESET_COLOR";
print << 'FINISHED';
Arch ARM installation finished.
Insert the memory card into your Raspberry Pi. Connect ethernet to network. Boot it up.
The default root password is 'root', and the default user/password is 'alarm'/'alarm'.
See the README for next steps.
FINISHED
}

sub check_device {
    -b $DEVICE or die "Device '$DEVICE' could not be found.";
    # TBD: Automated check for mmcblk0 safety?
}

sub setup_temp_dir {
    make_path($TEMP_DIR);
    make_path($KERNEL_DEPOT);
}

sub download_images {
    system("wget -P $TEMP_DIR $IMAGE_URL") == 0 or die "$!";
    system("wget -P $KERNEL_DEPOT $KERNEL_URL") == 0 or die "$!";
}

sub partition_device {
    my $commands = <<'COMMANDS';
,256M,0c,
,,,
COMMANDS
    open(my $fh, '|-', "sfdisk --wipe always $DEVICE") or die "$!";
    print $fh $commands;
    close $fh or die "Partitioning failed: $!";
}

sub format_partitions {
    system("mkfs.vfat -F 32 $BOOT_PARTITION") == 0 or die "$!";
    my $options = "-E lazy_itable_init=0,lazy_journal_init=0";
    system("mkfs.ext4 $options -F $ROOT_PARTITION") == 0 or die "$!";
}

sub mount_partitions {
    make_path($MOUNT_DIR);
    system("mount $ROOT_PARTITION $MOUNT_DIR") == 0 or die "$!";
    make_path("$MOUNT_DIR/boot");
    system("mount $BOOT_PARTITION $MOUNT_DIR/boot") == 0 or die "$!";
    system("sync") == 0 or die "$!";
}

sub install_arch_linux {
    system("tar -xpf $TEMP_DIR/$IMAGE_TAR -C $MOUNT_DIR") == 0 or die "$!";
    system("rm -rf $MOUNT_DIR/boot/*") == 0 or die "$!";
    system("tar -xpf $KERNEL_DEPOT/$KERNEL_TAR -C $TEMP_DIR") == 0 or die "$!";
    system("cp -rf $TEMP_DIR/boot/* $MOUNT_DIR/boot/") == 0 or die "$!";
}

sub cleanup {
    system("sync && umount -R $MOUNT_DIR") == 0 or die "$!";
    remove_tree($TEMP_DIR);
}

main();
