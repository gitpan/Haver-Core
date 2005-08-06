#!/usr/bin/perl
# vim: set ft=perl:

use POE;
use Test::More tests => 6;
BEGIN {
	use_ok('Haver::Session');
}




my $count = 10;
can_ok('MySession', 'create');
create MySession (
	count => $count,
);

my $o = new ObjSession;
$o->create(object => 1);
create ObjSession (object => 0);

create POE::Session (
	inline_states => {
		_start => sub {
			my ($kernel) = $_[KERNEL];
			$kernel->alias_set('tester');
		},
		ok    => sub {
			my ($kernel, $arg) = @_[KERNEL, ARG0];
			$kernel->alias_remove('tester');
			is($count, $arg);
		},
	},
);


POE::Kernel->run;
BEGIN {
	package MySession;
	use Haver::Session -base;
	use Test::More;

	sub states {
		return [qw( _start _stop loop )];
	}
	sub _start {
		my ($kernel, $heap, $opt) = @_[KERNEL, HEAP, ARG0];
		$heap->{count} = $opt->{count};
		$heap->{looped} = 0;
		post('loop');
		diag "Starting with a count of $heap->{count}";
		ok(($_[OBJECT] eq 'MySession'), "Are we a package state?");
		diag $_[OBJECT];
	}

	sub loop {
		my ($kernel, $heap) = @_[KERNEL, HEAP];
		if ($heap->{count}-- > 0) {
			$heap->{looped}++;
			post('loop');
		}
	}

	sub _stop {
		my ($kernel, $heap) = @_[KERNEL, HEAP];
		diag "Stopping after $heap->{looped} loops";
		$kernel->call('tester', 'ok', $heap->{looped});
	}
}

BEGIN {
	package ObjSession;
	use Haver::Session -base;
	use Test::More;

	sub states { [qw( _start )] }
	sub _start {
		my ($obj, $opt) = @_[OBJECT, ARG0];
		
		if ($opt->{object}) {
			ok((ref($obj) eq 'ObjSession'), "Are we an object state?");
		} else {
			ok(($obj eq 'ObjSession'), "Are we an object state?");
		}
	}
}

