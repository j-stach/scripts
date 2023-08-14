
# Script to disable/enable webcam by unloading/loading kernel module

use strict; use warnings;

sub cam_check {
    open(my $modlist, "-|", "lsmod | grep uvcvideo") 
    or die "Modlist failed"; 
    
    while (my $mod = <$modlist>) {
        if ($mod =~ /\buvcvideo\s+[0...9\s]+/) { 
            close $modlist;
            return 1;
        }
    }
    
    close $modlist;
    return 0;
}

sub cam_enable {
    system("sudo", "modprobe", "uvcvideo");
    if (&cam_check == 1) { print "Webcam reenabled! I see you now!\n" }
}

sub cam_disable {
    qx{sudo modprobe -r uvcvideo} or &force_cam_disable; 
    if (&cam_check == 0) { print "Webcam disabled. Bye!\n" }
}

sub force_cam_disable {
    print "Asking politely...\n";
    system("sudo", "rmmod", "-f", "uvcvideo")
}

if (&cam_check == 1) { 
    print "uvcvideo has been sighted...\n";
    &cam_disable 
}
elsif (&cam_check == 0) { &cam_enable }



