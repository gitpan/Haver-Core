# vim: set ts=4 sw=4 noexpandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Wheel::Loader;
use strict;
use warnings;
use Carp;

our $VERSION = '0.04';

sub new {
	my $class = shift;
	my $self = {
		wheels => {},
	};
	bless $self, $class;
}

sub load_wheel {
	my ($self, $class, @args) = @_;

	if (exists $self->{wheels}{$class}) {
		croak "Plugin $class already loaded!";
	}
	
	my $object = $class->new(@args);
	$object->load;
	$self->{wheels}{$class} = $object;
}

sub unload_wheel {
	my ($self, $class) = @_;
	my $object = delete $self->{wheels}{$class};
	$object->unload;
}

sub wheels {
	my $self = shift;
	keys %{ $self->{wheels} };
}

sub unload_all_wheels {
	my ($self) = @_;
	map { $self->unload($_) } $self->wheels
}

sub fetch_wheel {
	my ($self, $class) = @_;
	
	if (exists $self->{wheels}{$class}) {
		$self->{wheels}{$class};
	} else {
		undef;
	}
}


1;
__END__
=head1 NAME

Haver::Wheel::Loader - description

=head1 SYNOPSIS

  use Haver::Wheel::Loader;
  use MyPlugin;

  # ... In some POE state ...
  my $loader = Haver::Wheel::Loader;
  $loader->load_wheel('MyPlugin', 'some', 'args');
  $_[HEAP]{loader} = $loader;

=head1 DESCRIPTION

This object maintains a list of wheel objects which have states loaded into a session.

FIXME: Write a better description.

=head1 METHODS

This class implements the following methods:

=head2 new(Z<>)

This returns a new Haver::Wheel::Loader object.

=head2 load_wheel($class, @args)

Creates a new object of class $class, passing @args to its new() class method.
The newly created object will have its load() method called, which should load states into the
currently active L<POE::Session>.

For details on defining wheels, see L<POE::Session::Plugin>.

=head2 unload_wheel($class)

Call unload() on the object associated with $class,
and then destroy the said object.

=head2 wheels(Z<>)

Returns a list of the currently loaded class names.

=head2 fetch_wheel($class)

Returns the wheel object of type $class.
Returns undef if $class was never loaded.

=head2 unload_all_wheels(Z<>)

Unload all currently loaded wheels.

This is called when the wheel loader is DESTROY()'d, so you never really need to call it.

=head1 BUGS

None known. Bug reports are welcome. Please use our bug tracker at
L<http://gna.org/bugs/?func=additem&group=haver>.

=head1 AUTHOR

Dylan William Hardison, E<lt>dylan@haverdev.orgE<gt>

=head1 SEE ALSO

L<http://www.haverdev.org/>, L<POE>, L<POE::Session>, L<POE::NFA>.

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

