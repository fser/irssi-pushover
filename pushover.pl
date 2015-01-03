# Irssi plugin to notify pushover when highlight or private message
# This scripts implements a delay between two notifications, and only
# sends notification when user is away.

# Inspired by hilightwin.pl
# Tested with irssi 0.8.15

use Irssi;
use URI;
use LWP;
use vars qw($VERSION %IRSSI);

$VERSION     = "0.01";
$last_notif  = 0;
$NOTIF_DELAY = 30;
%IRSSI       = (
    authors => "fser",
    contact => "fser\@code-libre.org",
    name    => "pushover",
    description =>
      "notify user when highlighted/private messages using pushover REST API",
    license => "WTFPL – Do What the Fuck You Want to Public License",
    url     => "https://github.com/fser/irssi-pushover",
    changed => "2015-01-03T19h20:36+0100"
);

sub notify_android {
    my ($text)  = @_;
    my $url     = URI->new('https://api.pushover.net/1/messages.json');
    my $browser = LWP::UserAgent->new;
    $browser->post(
        $url,
        [
            'user'    => '<< set you own token here >>',
            'token'   => 'aGYm4jeuwLFQzixsU926coH9ByGTjK',
            'message' => $text
        ]
    );
}

sub sig_printtext {
    my ( $dest, $text, $stripped ) = @_;
    my $server = $dest->{server};

    # change to (MSGLEVEL_HILIGHT|MSGLEVEL_MSGS) to work for
    # all privmsgs too
    if (   ( $dest->{level} & (MSGLEVEL_HILIGHT) )
        && ( $dest->{level} & MSGLEVEL_NOHILIGHT ) == 0 )
    {
        if ( $dest->{level} & MSGLEVEL_PUBLIC ) {
            $text = $dest->{target} . ": " . $text;
        }
        $text =~ s/%/%%/g;
        if ( $server->{usermode_away} ) {
            my $now = time();
            if ( ( $now - $last_notif ) > $NOTIF_DELAY ) {
                notify_android $stripped;
                $last_notif = $now;
            }
        }
    }
}

Irssi::signal_add( 'print text', 'sig_printtext' );

