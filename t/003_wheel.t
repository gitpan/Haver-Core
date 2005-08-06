#!/usr/bin/perl
# vim: set ft=perl:
use strict;
use POE;
use Test::More tests => 14;

BEGIN { 
	use_ok('Haver::Wheel');
	use_ok('Haver::Wheel::Loader');
};
can_ok('Haver::Wheel', 'new');

my $plugin = new Haver::Wheel;
can_ok($plugin,
	qw(
		provide
		load
		unload
		define
		undefine
		provided_states
		defined_states
		setup
		kernel
	)
);

can_ok('Haver::Wheel::Loader', 'new');

my $loader = new Haver::Wheel::Loader;
can_ok($loader,
	qw(
		load_wheel
		unload_wheel
		wheels
		fetch_wheel
		unload_all_wheels
	)
);



POE::Session->create(
	inline_states => {
		_start => \&on_start,
		_stop  => \&on_stop,
		bye    => \&on_bye,
	},
);


sub on_start {
	my ($kernel, $heap) = @_[KERNEL, HEAP];
	my $loader = new Haver::Wheel::Loader;
	$loader->load_wheel('MyWheel');
	$loader->load_wheel('PkgWheel');
	$heap->{loader} = $loader;


	diag "Starting session";
	foreach my $state (qw( foo bar baz )) {
		$kernel->yield($state) for 1 .. 3;
	}
	$kernel->yield('gork');
}

sub on_stop {
	diag "Stopping session";
}

sub on_bye {
	my ($kernel, $heap) = @_[KERNEL, HEAP];
	my $loader = $heap->{loader};
	my $p = $loader->fetch_wheel('MyWheel');
	
	diag "Saying goodbye";
	is($p->{foo}, 3, "Called foo 3 times");
	is($p->{bar}, 3, "Called bar 3 times");
	is($p->{baz}, 3, "Called baz 3 times");
	
	diag "Calling foo again";
	$kernel->call($_[SESSION], 'foo');
	is($p->{foo}, 4, "foo is now 4");
	
	diag "Unloading MyWheel";
	$loader->unload_wheel('MyWheel');
	$kernel->call($_[SESSION], 'foo');
	isnt($p->{foo}, 5, "foo is not 5");
	ok($p->{load}, "on_load was called.");
	ok($p->{unload}, "on_unload was called.");
	ok(($PkgWheel::Gork == 1), 'package wheel worked');
}


	
	
POE::Kernel->run;

BEGIN {
	package MyWheel;
	use POE;
	use base 'Haver::Wheel';

	sub setup {
		my $self = shift;
		$self->provide('foo', 'on_foo');
		$self->provide('bar', 'on_bar');
		$self->provide('baz', 'on_baz');
	}

	sub on_load {
		my $self = $_[OBJECT];
		$self->{load} = 1;
	}

	sub on_unload {
		my $self = $_[OBJECT];
		$self->{unload} = 1;
	}
	sub on_foo { 
		my $self = $_[OBJECT];
		$self->{foo}++;
	}
	
	sub on_bar { 
		my $self = $_[OBJECT];
		$self->{bar}++;
	}

	sub on_baz {
		my $self = $_[OBJECT];
		$self->{baz}++;
		if ($self->{baz} == 1) {
			$_[KERNEL]->yield('bye');
		}
	}
}


BEGIN {
	package PkgWheel;
	use POE;
	use Test::More;
	use Haver::Wheel -base;
	our $Gork = 0;
	
	sub setup {
		my $self = shift;
		$self->provide('gork', 'on_gork');
	}
	sub package { 1 }
	sub on_gork {
		$Gork = ($_[OBJECT] eq 'PkgWheel');
	}
}
