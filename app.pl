use Mojo::SlackRTM;
use lib 'lib';
use Meinhator qw(should_react extract_citated_ids);

# get from https://api.slack.com/web#authentication
my $token    = $ENV{SLACK_TOKEN}    // die "Please set the SLACK_TOKEN variable";
my $reaction = $ENV{SLACK_REACTION} // "100";
my $user     = $ENV{SLACK_USER};
my $uid      = $ENV{SLACK_USER_ID};
my $lookfor  = $ENV{SLACK_LOOKFOR};

my $slack = Mojo::SlackRTM->new(token => $token);
$slack->on(message => sub {
    my ($slack, $event) = @_;
    my $channel_id = $event->{channel};
    my $user_id    = $event->{user};
    my $user_name  = $slack->find_user_name($user_id);
    my $ts         = $event->{ts};
    my $text       = $event->{text};

    # Extract @-mentioned user IDs and resolve to names
    my $citated_ids = extract_citated_ids($text);
    my @citated = map { $slack->find_user_name($_) } @$citated_ids;
    $slack->log->debug("Citated: " . join ", ", @citated) if @citated;

    if (should_react(
        user_id        => $user_id,
        user_name      => $user_name,
        text           => $text,
        citated        => \@citated,
        config_uid     => $uid,
        config_user    => $user,
        config_lookfor => $lookfor,
    )) {
        $slack->call_api("reactions.add", {
            name      => $reaction,
            channel   => $channel_id,
            timestamp => $ts,
        });
    }
});
$slack->start;
