# vim: set ts=4 sw=4 noexpandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Wheel;
use strict;
use warnings;

use Haver::Base -base;
use POE::Session;
use POE::Wheel;
use Haver::Session 'call', 'post';
our $VERSION = 0.08;
our @EXPORT_BASE = qw(
	SESSION OBJECT
	KERNEL HEAP STATE
	SENDER CALLER_FILE
	CALLER_LINE ARG0
	ARG1 ARG2 ARG3
	ARG4 ARG5 ARG6
	ARG7 ARG8 ARG9
	call post
);

const kernel  => $POE::Kernel::poe_kernel;
field package => 0;

sub new {
	my $class = shift;
	my $self = {
		# I only prefix these with underscores because I am paranoid of
		# subclasses clobbering them. :)
		_provided_states => [],
		_defined_states  => { },
		_id              => POE::Wheel::allocate_wheel_id(),
	};
	bless $self, $class;
	$self->provide("load_$self->{_id}", 'on_load');
	$self->provide("unload_$self->{_id}", 'on_unload');
	$self->setup(@_);
	return $self;
}

sub setup {  }

# POE state called when we load.
sub on_load {
	
}

# POE state called when we unload.
sub on_unload {
	
}

sub provide {
	my ($self, $state, $method) = @_;
	croak "state name undefined!" unless defined $state;
	push @{ $self->{_provided_states} }, [ $state, $method ];
}

sub provided_states {
	my $self = shift;
	@{ $self->{_provided_states} };
}

sub defined_states {
	my $self = shift;
	keys %{ $self->{_defined_states} };
}


sub invoke {
	my $self = shift;
	my $act  = shift;
	my $kernel = $self->kernel;
	my $session = $kernel->get_active_session();
	my $class   = ref $self;
	$kernel->call($session, join('_', $act, $self->ID));
}

sub ID { shift->{_id} }

# Load all provided states.
sub load {
	my $self = shift;
	map {
		$self->define(@$_)
	} $self->provided_states;
	$self->invoke('load');
}

# Unload all *defined* states.
sub unload {
	my $self = shift;
	$self->invoke('unload');
	map {
		$self->undefine($_)
	} $self->defined_states;
}

sub define {
	my ($self, $state, $method) = @_;
	my $kernel = $self->kernel;
	$method ||= $state;

	croak "State $state defined; can't redefine"
		if exists $self->{_defined_states}{$state};
	$self->{_defined_states}{$state} = $method;
	$kernel->state($state, 
		$self->package ? ref $self : $self,
		$method
	);
}

sub undefine {
	my ($self, $state) = @_;

	croak "State $state not defined; can't undefine"
	 	unless exists $self->{_defined_states}{$state};
	delete $self->{_defined_states}{$state};
	$self->kernel->state($state);
}


sub DESTROY {
	my $self = shift;
	POE::Wheel::free_wheel_id($self->ID);
}

1;
__END__
=head1 NAME

Haver::Wheel - Base class for modules that extend POE::Session at runtime.

=head1 SYNOPSIS

	package MyPlugin;
	use POE;
	use base 'Haver::Wheel';

	sub setup {
		my $self = shift;
		$self->provide('foo', 'on_foo');
	}

	sub on_foo {
		my ($kernel, $heap, $self) = @_[KERNEL, HEAP, OBJECT];
		# ...
	}

=head1 DESCRIPTION

This module allows the loading and unloading of object states into a running L<POE::Session>.

Plugins are not unlike a L<POE::Wheel>, except instead of producing events, they respond to them.

This behavior is similar to that of L<POE::NFA>, except it is added to existing L<POE::Session>
sessions.

=head1 METHODS

This class implements the following methods:

=head2 new(@args)

This returns a new wheel object.
Its arguments (@args) are passed to setup()

=head2 setup(Z<>)

B<Do not call this method>. It is called by new().

Subclasses should overload this method and use it call provide()
to specify which states they define in the current session.

=head2 ID(Z<>)

This returns the unique wheel id of the square wheel.

=head2 define($state [, $method ])

Bind $state in the currently active session to the method $method of $self.
If $method is omitted, it defaults to the same name as $state.

=head2 undefine($state)

Remove the binding of $state in the current session, if and only if it was previously
defined by our $self.

=head2 provide($state [, $method ])

This is like a delayed define(). It will only occurs when load() is called.

=head2 load(Z<>)

Load all C<provide>'d states.

=head2 unload(Z<>)

This undefines (with undefine()) all states that were defined with define()
or provided() and subsequently loaded with load().

=head2 on_load

This is method is called as a POE state when the plugin is loaded.
$_[KERNEL], $_[SESSION], etc, should all be correct.

=head2 on_unload

This is method is called as a POE state when the plugin is unloaded.
$_[KERNEL], $_[SESSION], etc, should all be correct.

=head1 BUGS

None known. Bug reports are welcome. Please use our bug tracker at
L<http://gna.org/bugs/?func=additem&group=haver>.

=head1 AUTHOR

Dylan William Hardison, E<lt>dylan@haverdev.orgE<gt>

=head1 SEE ALSO

L<http://www.haverdev.org/>, L<Haver::Wheel::Loader>,
L<POE>, L<POE::Session>, L<POE::NFA>.

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

