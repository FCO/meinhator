# meinhator

A Slack bot that automatically adds reactions to messages based on configurable
criteria. Built with [Mojolicious](https://mojolicious.org) and
[Mojo::SlackRTM](https://metacpan.org/pod/Mojo::SlackRTM).

## Features

- Listens to all Slack messages via the RTM API
- Reacts with a configurable emoji when the bot's user is mentioned,
  a specific keyword is found, or a user is @-mentioned
- Configurable entirely through environment variables

## Requirements

- Perl 5.20+
- [Carton](https://metacpan.org/pod/Carton) for dependency management
- A Slack workspace with a [bot token](https://api.slack.com/authentication)

## Installation

```bash
# Install dependencies
carton install

# Or using cpanm directly
cpanm --installdeps .
```

## Configuration

All configuration is done via environment variables:

| Variable         | Required | Default | Description |
|-----------------|----------|---------|-------------|
| `SLACK_TOKEN`   | Yes      | —       | Slack bot OAuth token |
| `SLACK_REACTION`| No       | `100`   | Emoji to use as reaction (e.g., `thumbsup`, `100`) |
| `SLACK_USER`    | No       | —       | Username to watch for (mentions or literal matches) |
| `SLACK_USER_ID` | No       | —       | User ID to watch for |
| `SLACK_LOOKFOR` | No       | —       | Keyword to trigger reaction when found in any message |

When `SLACK_USER`, `SLACK_USER_ID`, or `SLACK_LOOKFOR` is set, the bot will
only react to messages matching at least one of the criteria. If none are set,
the bot reacts to **every message** in channels it can see.

## Usage

```bash
# Set your Slack token
export SLACK_TOKEN=xoxb-your-token-here

# (Optional) React with a specific emoji
export SLACK_REACTION=thumbsup

# (Optional) Watch for a specific user
export SLACK_USER=john

# Start the bot
carton exec perl app.pl
```

### Docker

```bash
docker build -t meinhator .
docker run -e SLACK_TOKEN=xoxb-your-token-here meinhator
```

## License

This project is licensed under the same terms as Perl itself — see the
[LICENSE](LICENSE) file for details.
