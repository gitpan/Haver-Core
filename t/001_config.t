#!/usr/bin/perl
# vim: set ft=perl:

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
BEGIN {
	use_ok('Haver::Config');
};

can_ok('Haver::Config', qw( 
	new config get set load save reload file merge
));


if (-e 'foobar') {
	unlink 'foobar' or die "Can't remove foobar!";
}
my $ch = new Haver::Config;
$ch->load('foobar');
$ch->merge(
	{
        stuff => {
            monkeys => 2,
        },
        foo => 'bar',
        baz => [ { name => "bob" } ],
    }
);
my $stuff = {
	stuff => { monkeys => 2 },
	foo => 'bar',
    baz => [ { name => "bob" } ],
};
my $c = $ch->config;

is_deeply($c, $stuff, "Config with default values");
ok(($ch->get('foo') eq 'bar'), "get()");
$ch->set(bar => 'baz');
ok(($ch->get('bar') eq 'baz'), "get()");

$ch->save;

my $ch2 = new Haver::Config;
$ch2->load('foobar');
$ch2->merge($stuff);

is_deeply($ch->config, $ch2->config, "Saved properly");

is(eval { $ch->foo }, 'bar', "AUTOLOAD");
