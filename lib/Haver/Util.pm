# vim: set ts=4 sw=4 noexpandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Util;
use strict;
use warnings;

use base 'Exporter';

our $VERSION     = 0.02;
our @EXPORT      = ();
our @EXPORT_OK   = qw( is_valid_name is_reserved_name is_known_namespace );
our %EXPORT_TAGS = (
	name => [qw( is_valid_name is_reserved_name )],
	ns   => [qw( is_known_namespace )],
	all  => [@EXPORT_OK],
);

our $NamePattern = qr/^&?[a-z][a-z0-9_.'\@-]+$/i;

sub is_valid_name {
	my $name = shift;
	return undef unless defined $name;
	$name =~ $NamePattern;
}

sub is_reserved_name {
	my $name = shift;
	return undef unless defined $name;
	$name =~ /^&/ or $name =~ /@/;
}

sub is_known_namespace {
	my $ns = shift;
	$ns and ($ns eq 'user' or $ns eq 'channel' or $ns eq 'service')
}


1;
__END__
=head1 NAME

Haver::Util - description

=head1 SYNOPSIS

  use Haver::Util;
  # Small code example.

=head1 DESCRIPTION

FIXME

=head1 EXPORTS

This module optionally exports the following functions.

=head2 is_valid_name($name)

Returns true if $name is considered a valid haver name, false otherwise.

=head2 is_reserved_name($name)

Returns true if $name is only available for services and other privledged entities.

=head1 EXPORT GROUPS

=head1 BUGS

None known. Bug reports are welcome. Please use our bug tracker at
L<http://gna.org/bugs/?func=additem&group=haver>.

=head1 AUTHOR

Dylan William Hardison, E<lt>dylan@haverdev.orgE<gt>

=head1 SEE ALSO

L<http://www.haverdev.org/>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2005 by Dylan William Hardison. All Rights Reserved.

This module is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This module is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this module; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

