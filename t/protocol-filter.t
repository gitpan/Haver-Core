#!/usr/bin/perl
# vim: set ft=perl:
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Haver.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';


use Test::More;
if (eval "require POE; 2") {
	plan tests => 9;
} else {
	plan skip_all => 'Test irrelevant without POE';
}


use_ok('POE::Filter::Haver');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my $f = new POE::Filter::Haver;
my $s = "MSG\tdylan\tbunnies\et\eet\x0D\x0A";
is($f->put($f->get([$s]))->[0], $s, 'filter input is filter output');

is_deeply($f->get([$s]), [ ['MSG', 'dylan', "bunnies\t\et"] ], "deep sanity");


$s = "Tab: \t Esc: \e R: \r N: \n";
my $o = $f->put([["dummy", $s]]);
$o = $f->get($o);

is_deeply($o, [['dummy', $s]], "deep sanity 2");

$o = $o->[0]->[1];
is($o, $s, 'escaping');

my $in = "This is some input: Tab \t Esc: \e CR: \r LF: \n. Happy?";
my $out = "OUT\tThis is some input: Tab \et Esc: \ee CR: \er LF: \en. Happy?\r\n";
is($f->put([['OUT', $in]])->[0], $out, "sanity");
$o = $f->get([$out]);
is($o->[0][1], $in, "sanity 2");

$f->get_one_start([$out]);
$o = $f->get_one;
is($o->[0][1], $in, "sanity 3");

$o = ['ONE', "\r\e\n\t"];
$f->put([$o]);
$f->put([$o]);
is_deeply($o, ['ONE', "\r\e\n\t"], "no change");



