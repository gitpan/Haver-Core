# vim: set ts=4 sw=4 noexpandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Logger;
use strict;
use warnings;
use Carp;
use Exporter;
use base 'Exporter';

our $VERSION   = 0.02;
our @EXPORT_OK = qw( Log );

sub Log (@) {
	if (@_ == 1) {
		#$POE::Kernel::poe_kernel->post('Logger', 'debug', @_);
		print "[debug] ", @_, "\n";
	} elsif (@_ > 1) {
		#$POE::Kernel::poe_kernel->post('Logger', @_);
		my $s = shift;
		print "[$s] ", @_, "\n";
	} else {
		croak 'Log() must be called with >= 1 arguments';
	}
}

1;
