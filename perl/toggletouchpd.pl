
# Script to disable/enable touchpad through Hyprland.
# Inspired by u/sixsupersonic on Reddit:
# reddit.com/r/hyprland/comments/11kr8bl/hotkey_disable_touchpad/

use strict; use warnings;

my $touchpd = &get_tpd;
my $tpd_status = &tpd_status;

my $status_error = 
"WARNING: Failed to read $tpd_status. Defaulting to 'true'\n";

&toggle_touchpd;


sub get_tpd {
    if (open my $th, "-|", "hyprctl devices | grep -A1 'Mouse'") {
        <$th>;
        while (my $t = <$th>) {
            if ($t =~ /^\s+(?<tpd>.+)$/) {
                my $tpd = $+{tpd};
                close $th;
                return $tpd
            }
        }
        close $th
    } else { die "ERROR: Failed to get touchpad device\n" }
}

sub tpd_status {
    my $tpd_file;
    if (my $hyprland = $ENV{XDG_RUNTIME_DIR}) {
        $tpd_file = $hyprland."/touchpad.status";
    } else { die "ERROR: No XDG runtime directory found.\n" }
    return $tpd_file
}

sub toggle_touchpd {
    my $new_status;
    unless (-e $tpd_status) { 
        system("touch $tpd_status");
        print "Made $tpd_status for ya, you're welcome\n";
        $new_status = "true" 
    }

    if (open my $tsh, '<', $tpd_status) {
        my $s = <$tsh>;
        if ($s =~ "true") { $new_status = "false" }
        elsif ($s =~ "false") { $new_status = "true" }
        else { print $status_error; $new_status = "true" }
        close $tsh;
    } else { print $status_error; $new_status = "true" }

    if (open my $tsh, '>', $tpd_status) {
        print $tsh "$new_status";
        close $tsh;
    } else { print "WARNING: Failed to alter $tpd_status\n" }

    qx{hyprctl keyword "device:$touchpd:enabled" $new_status};
    print "Touchpad enabled: ".&check_status."\n";
}

sub check_status {
    if (open my $tsh, '<', $tpd_status) {
        my $s = <$tsh>;
        close $tsh;
        return $s
    } else { print $status_error }
}

