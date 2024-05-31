
#!/usr/bin/perl
# Setup component to correct Arch installation for RaspberryPi.
# Intended to be run after booting into a new installation for the first time.

sub main {
    &pacman_setup;
    system("reboot");
}

sub pacman_setup {
    system("pacman-key --init");
    system("pacman-key --populate archlinuxarm");
    system("pacman -R linux-aarch64 uboot-raspberrypi");
    system("pacman -Syu --overwrite \"/boot/*\" linux-rpi");
}
