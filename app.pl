use Mojo::SlackRTM;

# get from https://api.slack.com/web#authentication
my $token	= $ENV{SLACK_TOKEN}	// die "Please set the SLACK_TOKEN variable";
my $reaction	= $ENV{SLACK_REACTION}	// "100";
my $user	= $ENV{SLACK_USER};

my $slack = Mojo::SlackRTM->new(token => $token);
$slack->on(message => sub {
	my ($slack, $event) = @_;
	my $channel_id	= $event->{channel};
	my $user_id	= $event->{user};
	my $user_name	= $slack->find_user_name($user_id);
	my $ts		= $event->{ts};
	if(not defined $user or lc $user_name eq lc $user) {
		$slack->call_api("reactions.add", {
			name		=> $reaction	,
			channel		=> $channel_id	,
			timestamp	=> $ts		,
		});
	}
});
$slack->start;
