# vim: set ft=perl ts=4 sw=4 sta si ai tw=100 expandtab:
# Haver::Protocol::Filter
# This is a POE filter for the Haver protocol.
# It subclasses POE::Filter::Line.
# 
# Copyright (C) 2003-2004 Bryan Donlan
# Modifications and docs Copyright (C) 2004 Dylan William Hardison
#
# This module is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This module is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this module; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
package Haver::Protocol::Filter;
use warnings;
use strict;
use POE;
use base qw(POE::Filter::Line);
use Haver::Protocol qw( $CRLF %Escape %Unescape );

our $VERSION = "0.02";

sub new {
	my ($this) = @_;
	
	return $this->SUPER::new(
		OutputLiteral => $CRLF,
		InputRegexp => qr/\r?\n/,
	);
}

# This is not needed any more, so let's not use it.
#sub get {
#	my ( $self, $arg) = @_;
#	my $lines = $self->SUPER::get($arg);
#
#	foreach my $line (@{$lines}) {
#		my @f = split("\t", $line);
#		
#		foreach my $item (@f) {
#			$item =~ s/\e([rent])/$Unescape{$1}/g;
#		}
#		$line = \@f;
#	}
#	return $lines;
#}

sub get_one {
	my ($self) = @_;
	my $lines = $self->SUPER::get_one;

	foreach my $line (@{$lines}) {
		my @f = split("\t", $line);
		
		foreach my $item (@f) {
			$item =~ s/\e([rent])/$Unescape{$1}/g;
		}
		$line = \@f;
	}
	return $lines;
}

sub put {
	my ( $self, $arg ) = @_;
	my @ret;
	foreach my $msg (@{$arg}) {
		my @msg;
		foreach my $item (@$msg) {
			my $s = $item;
			if (defined $s) {
				$s =~ s/([\r\e\n\t])/\e$Escape{$1}/g;
			} else {
				$s = '';
			}
			push(@msg, $s);
		}
		push(@ret, join "\t", @msg);
	}
	return $self->SUPER::put(\@ret);
}

1;


1;
__END__

=head1 NAME

Haver::Protocol::Filter - POE::Filter for the Haver protocol.

=head1 SYNOPSIS

  use Haver::Protocol::Filter;
  my $filter = new Haver::Protocol::Filter; # takes no arguments.
  
  # See POE::Filter. This is just a standard filter.
  # it inherits from POE::Filter::Line.

=head1 DESCRIPTION

This POE::Filter translates strings like "MSG\tdylan\tbunnies\xD\xA"
to and from arrays like ['MSG', 'dylan', 'bunnies'].

=head1 SEE ALSO

L<POE::Filter>, L<POE::Filter::Line>.

L<https://savannah.nongnu.org/projects/haver/>, L<http://wiki.chani3.com/wiki/ProjectHaver/Protocol>,
L<http://wiki.chani3.com/wiki/ProjectHaver/ProtocolSyntax>.

=head1 AUTHOR

Bryan Donlan, E<lt>:bdonlan@gmail.comE<gt>
with small modifications and documentation by
Dylan William Hardison, E<lt>dylanwh@tampabay.rr.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2004 by Bryan Donlan.
Modifications and docs Copyright (C) 2004 Dylan William Hardison.

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this module; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=cut


sub new {
	my ($this) = @_;
	my $me = bless {}, ref($this) || $this;

	# ...

	return $me;
}


1;

