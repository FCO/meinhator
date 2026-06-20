use strict;
use warnings;
use Test::More;

use lib 'lib';
use Meinhator qw(should_react extract_citated_ids);

# --- No filters: react to everything ---
ok should_react(
    user_id   => 'U123',
    user_name => 'john',
    text      => 'hello world',
    citated   => [],
), 'no filters → react to everything';

# --- SLACK_USER_ID match ---
ok should_react(
    user_id      => 'U123',
    user_name    => 'john',
    text         => 'hello',
    citated      => [],
    config_uid   => 'U123',
), 'config_uid matches message user_id (case insensitive)';

ok should_react(
    user_id      => 'U123',
    user_name    => 'john',
    text         => 'hello',
    citated      => [],
    config_uid   => 'u123',
), 'config_uid matches with different case';

ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hello',
    citated      => [],
    config_uid   => 'U123',
), 'config_uid does not match → no react';

# --- SLACK_USER match by user_name ---
ok should_react(
    user_id      => 'U456',
    user_name    => 'john',
    text         => 'hello',
    citated      => [],
    config_user  => 'john',
), 'config_user matches message user_name';

ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hello',
    citated      => [],
    config_user  => 'john',
), 'config_user does not match user_name → no react';

# --- SLACK_USER match by @-mention (citated) ---
ok should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hey <@U123>!',
    citated      => ['john'],
    config_user  => 'john',
), 'config_user found in citated names';

ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hey <@U123>!',
    citated      => ['joe'],
    config_user  => 'john',
), 'config_user NOT in citated → no react';

# Empty citated array
ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hey',
    citated      => [],
    config_user  => 'john',
), 'empty citated with only config_user → no react';

# --- SLACK_USER match by literal text ---
ok should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hey john how are you',
    citated      => [],
    config_user  => 'john',
), 'config_user found as word boundary in text';

ok should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'Hey JOHN!',
    citated      => [],
    config_user  => 'john',
), 'case insensitive literal match';

ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'johnson is here',
    citated      => [],
    config_user  => 'john',
), 'word boundary — johnson does NOT match john';

# --- SLACK_LOOKFOR match ---
ok should_react(
    user_id         => 'U456',
    user_name       => 'jane',
    text            => 'I love pizza today',
    citated         => [],
    config_lookfor  => 'pizza',
), 'config_lookfor found in text';

ok !should_react(
    user_id         => 'U456',
    user_name       => 'jane',
    text            => 'I love pizzaria',
    citated         => [],
    config_lookfor  => 'pizza',
), 'lookfor respects word boundary — pizzaria no match';

ok !should_react(
    user_id         => 'U456',
    user_name       => 'jane',
    text            => 'random chat',
    citated         => [],
    config_user     => 'john',
    config_lookfor  => 'pizza',
), 'multiple filters set but none match → no react';

# --- Combo: user + lookfor ---
ok should_react(
    user_id         => 'U456',
    user_name       => 'jane',
    text            => 'did someone say pizza?',
    citated         => [],
    config_user     => 'john',
    config_lookfor  => 'pizza',
), 'lookfor matches even when config_user does not';

# --- Undefined text ---
ok !should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => undef,
    citated      => [],
    config_user  => 'john',
), 'undef text with config_user set → no match';

# --- Boundary cases ---
ok should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'John.',
    citated      => [],
    config_user  => 'john',
), 'word boundary with punctuation after name';

ok should_react(
    user_id      => 'U456',
    user_name    => 'jane',
    text         => 'hey @John!',
    citated      => [],
    config_user  => 'john',
), 'word boundary — @ does not prevent match';

# --- extract_citated_ids ---
is_deeply extract_citated_ids('hello <@U123> how are you'),
    ['U123'],
    'extract single citated ID';

is_deeply extract_citated_ids('<@U123> <@U456|jane>'),
    ['U123', 'U456'],
    'extract multiple citated IDs with pipe format';

is_deeply extract_citated_ids('no mentions here'),
    [],
    'no mentions → empty array';

is_deeply extract_citated_ids(undef),
    [],
    'undef text → empty array';

done_testing;
