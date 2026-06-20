package Meinhator;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(should_react extract_citated_ids);

=encoding utf8

=head1 NAME

Meinhator — Slack bot reaction decision logic

=head1 SYNOPSIS

    use Meinhator qw(should_react extract_citated_ids);

    my @citated_ids = @{ extract_citated_ids($text) };
    # resolve IDs to names via Slack API...
    my $react = should_react(
        user_id   => $event->{user},
        user_name => $user_name,
        text      => $event->{text},
        citated   => \@citated_names,
        config_uid      => $ENV{SLACK_USER_ID},
        config_user     => $ENV{SLACK_USER},
        config_lookfor  => $ENV{SLACK_LOOKFOR},
    );

=head1 FUNCTIONS

=head2 should_react(%args)

Decides whether the bot should react to a message.

    my $bool = should_react(
        user_id        => 'U123',           # Slack user ID of message author
        user_name      => 'john',           # resolved display name
        text           => 'hello world',    # message text
        citated        => [],               # arrayref of resolved names from @-mentions
        config_uid     => undef,            # $ENV{SLACK_USER_ID}
        config_user    => undef,            # $ENV{SLACK_USER}
        config_lookfor => undef,            # $ENV{SLACK_LOOKFOR}
    );

=head2 extract_citated_ids($text)

Extracts user IDs from Slack @-mention syntax in message text.

    my $ids = extract_citated_ids('hello <@U123> <@U456|jane>');
    # ['U123', 'U456']

=cut

sub should_react {
    my %args = @_;

    my $user_id   = $args{user_id};
    my $user_name = $args{user_name};
    my $text      = $args{text};
    my $citated   = $args{citated} // [];
    my $uid       = $args{config_uid};
    my $user      = $args{config_user};
    my $lookfor   = $args{config_lookfor};

    # No filters set at all → react to everything
    return 1 if !defined $user && !defined $uid && !defined $lookfor;

    # SLACK_USER_ID matches message author's ID (case insensitive)
    if (defined $uid && defined $user_id && lc $uid eq lc $user_id) {
        return 1;
    }

    # SLACK_USER matches message author's name (case insensitive)
    if (defined $user && defined $user_name && lc $user_name eq lc $user) {
        return 1;
    }

    # SLACK_USER found in @-mentioned (citated) names
    if (defined $user && grep { defined && lc $_ eq lc $user } @$citated) {
        return 1;
    }

    # SLACK_USER found as word boundary in text
    if (defined $user && defined $text && $text =~ /\b\Q$user\E\b/i) {
        return 1;
    }

    # SLACK_LOOKFOR keyword found as word boundary in text
    if (defined $lookfor && defined $text && $text =~ /\b\Q$lookfor\E\b/i) {
        return 1;
    }

    return 0;
}

sub extract_citated_ids {
    my ($text) = @_;
    return [] unless defined $text;
    my @ids = $text =~ /<@(.+?)(?:\|.+?)?>/g;
    return \@ids;
}

1;

=head1 AUTHOR

Fernando Correa de Oliveira <fco@cpan.org>

=head1 LICENSE

This project is licensed under the same terms as Perl itself.

=cut
