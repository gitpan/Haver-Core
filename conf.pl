#!/usr/bin/perl

use strict;
use warnings;
use Haver::Config;

my $conf = new Haver::Config(
	file => 'foo.yml',
	default => {
		name => $ENV{USER},
		pid  => $$,
		other => [1, 2, 3, 4],
		data => {
			crazy => "I am crazy"
		},
	},
);
use Data::Dumper;

print Dumper($conf);



