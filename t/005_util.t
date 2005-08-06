#!/usr/bin/perl
# vim: set ft=perl:

use Test::More tests => 14;
BEGIN {
	use_ok('Haver::Util', qw( is_valid_name is_reserved_name ));
};

ok(is_reserved_name('&bob'), "is_reserved_name");
ok(is_reserved_name('bob@host.org'), "is_reserved_name");
ok(not(is_reserved_name('bob')), "is_reserved_name");
ok(is_valid_name(q{foo}), "is_valid_name");
ok(is_valid_name(q{o'foo}), "is_valid_name");
ok(is_valid_name(q{foo@bar.org}), "is_valid_name");
ok(is_valid_name(q{o'foo1-2_bar@baz.org}), "is_valid_name");
ok(not(is_valid_name('123')), 'is_valid_name');
ok(not(is_valid_name('foo%bar')), 'is_valid_name');
ok(not(is_valid_name('#foo')), 'is_valid_name');
ok(not(is_valid_name(undef)), 'is_valid_name');
ok(not(is_valid_name('')), 'is_valid_name');
ok(not(is_valid_name(' ')), 'is_valid_name');


