
# Script to mute/unmute my microphone using pactl (Pulse Audio control)
# without involving PipeWire

use strict; use warnings; 

#&mic_toggle;
&mic_status;

sub mic_toggle { 
    system('pactl', 'set-source-mute', '@DEFAULT_SOURCE@', 'toggle'); 
}

sub mic_source { system("pactl", "get-default-source") }
my $sauce_error = "Can't sauce your mic bruh that's my b"; 
my $status_error = "Can't read your mic status bruh that's my b";

sub mic_status { 
    open(my $src, "-|", "pactl", "get-source-mute", &mic_source) 
    or die "$sauce_error"; 

    while (my $status = <$src>) {
        if ($status =~ "Mute: no") { 
            print("Microphone can hear you bruh\n") 
        }
        elsif ($status =~ "Mute: yes") { 
            print("Microphone is muted bruh\n") 
        }
        else { die "$status_error" }
    }

    close $src
}

