#!/usr/bin/perl
 
use warnings;
use lib '/usr/local/lib/perl5/site_perl/5.12.2';
use lib '/usr/local/lib/perl5/site_perl/5.12.2/darwin-2level';
use Net::OSCAR;
use Audio::MPD;

use IO::Prompt;


#Hacked together by curdog
#sources: http://www.webreference.com/perl/tutorial/13/3.html
# and Audio::MPD from CPAN
# and http://stackoverflow.com/questions/701078/how-can-i-enter-a-password-using-perl-and-replace-the-characters-with

#music man hook up perl script
#mpd setup
my $mpd = Audio::MPD->new;
#guarantee it is playing...
$mpd->play;

#logon to aim
print 'Screen: ';
chomp( $nick = <>);
#my $aim = new Net::AIM;

chomp( $password = prompt('Password:', -e => '*') );
print 'Logging in to aim';
my $oscar = Net::OSCAR->new();
$oscar->set_callback_im_in(\&on_im);
$oscar->set_callback_error(\&got_error);
$oscar->signon($nick, $password);
#$oscar->signon_done(\&on_login);
#clear out password for a least a little security....
#cue evil laughter... then nervous chuckles...
$password = '';
$oscar->send_im( 'curdog4362', "logged in and ready for commands" );
while(1){
    $oscar->do_one_loop();
}

#message handler;
#1: play/pause
#2: next song in playlist
sub on_login{
    print "we are good to go!!!\n";
}

sub got_error{
    print @_;
}

sub on_im {
    my ($oscar, $sender, $message, $is_away) = @_;
    chomp( $message = $message); 
    #fuck html
    $message =~ s/<(.|\n)+?>//g;
    #
    @strs = split( / /, $message );
    $code = $strs[0];
    if( $code eq 'play' || $code eq 'pause' ){
       $mpd->pause;
       $oscar->send_im($sender, "Togggled play/pause");
    } 
    elsif ( $code eq 'next' ){
	$mpd->next;
	$oscar->send_im($sender, "Next Song");
    }
    elsif( $code eq 'vol' ){
	$mpd->volume( $strs[1] );
    }
    else {
	$oscar->send_im($sender, "Unknown Command: $message");
    }
   
}
