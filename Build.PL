#!/usr/bin/perl
use Module::Build;
my $build = Module::Build->new(
	module_name        => 'Haver::Core',
	dist_author        => 'Dylan William Hardison <dhardison@cpan.org>',
	license            => 'gpl',
	requires           => {
		'perl'           => '5.6.1',
		YAML             => '0.35',
		'Filter::Simple' => 0,
		Spiffy           => 0.21,
		POE              => 0.29,
	},
	suggests  => {
		'Haver::Server' => 0.08,
		'Haver::Client' => 0.08,
		'POE'           => 0.30,
	},
	create_makefile_pl => 'passthrough',
	# XXX: This is a hack, feel free to remove it...
	($ENV{USER} eq 'dylan') ? (sign => 1) : (),
);


$build->create_build_script;
