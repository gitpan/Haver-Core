#!/usr/bin/perl
# vim: set ft=perl:
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Haver.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
BEGIN {
	use_ok('Haver');
	use_ok('Haver::Protocol', qw(:event :crlf :escape));
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
{
	my $s = "bunnies\et\eet\er\en";
	is(escape(unescape($s)), $s, "escape and unescape work properly");
}
{
	my $in  = ["This", "is", "a test", "of \r\e\n\t"];
	my $out = "This\tis\ta test\tof \er\ee\en\et$CRLF";
	is(event2line($in), $out, "event2line");
	is_deeply([line2event($out)], $in, "line2event");
	is(event2line(line2event($out)), $out, "input is output");
}

