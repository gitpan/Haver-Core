# vim: set ts=4 sw=4 noexpandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Session;
use strict;
use warnings;

use Haver::Base -base;
use Haver::Logger 'Log';
use POE;

our $VERSION = 0.08;
our @EXPORT_BASE = qw(
	SESSION OBJECT
	KERNEL HEAP STATE
	SENDER CALLER_FILE
	CALLER_LINE ARG0
	ARG1 ARG2 ARG3
	ARG4 ARG5 ARG6
	ARG7 ARG8 ARG9
	Log call post
);
our @EXPORT_OK = qw( call post );

sub import (@) {
	if (grep /^-(Base|selfless)$/, @_) {
		croak "Haver::Base::Session subclasses may not use -Base or -selfless!";
	}
	my $package = caller();
	shift->SUPER::import(-package => $package, @_);
}

sub call (@) {
	$poe_kernel->call($poe_kernel->get_active_session, @_);
}

sub post (@) {
	$poe_kernel->yield( @_);
}

sub create () {
	my $this = shift;
	my $what = ref $this ? 'object' : 'package';

	create POE::Session (
		"${what}_states" => [
			$this => $this->states,
		],
		args => [ { @_ } ],
	)
}

1;
