# Haver::Base - Base class for most objects in Haver.
# 
# Copyright (C) 2004 Dylan William Hardison
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
package Haver::Base;
use strict;
use warnings;
use Haver::Preprocessor;

our $VERSION = "0.01";
use overload; 

sub new {
	my $this = shift;
	my $me   = @_ == 1 && ref($_[0]) ?  shift : { @_ };
	my $type = ref $me;
	bless $me, ref($this) || $this;

	delete $me->{$_} foreach (grep(/^_/, keys %$me));

	if ($type eq 'HASH') {
		if (!@_ and exists $me->{'-initargs'}) {
			@_ = @{ delete $me->{'-initargs'} };
		}
	}
	
	DEBUG: "DEBUG: Creating object: ", overload::StrVal($me);

	$me->initialize(@_);

	return $me;
}

sub initialize {undef}
sub finalize   {undef}

sub DESTROY {
	my $me = shift;
	
	
	DEBUG: "DEBUG: Destroying object: ", overload::StrVal($me);
	$me->finalize();
}


1;

__END__

=head1 NAME

Haver::Base - Useful base class for most objects in Haver server and clients.

=head1 SYNOPSIS

   BEGIN { 
   package Foobar;
   use base 'Haver::Base';

   sub initialize {
       my ($me, @args) = @_;
       print "init args: join(', ', @args), "\n";
   }

   sub finalize {
      my ($me) = @_;
      # do stuff here that you would do in DESTROY.
   }
   } # BEGIN

   my $foo = new Foobar({name => "Foobar"}, 1, 2, 3);
   # or: my $foo = new Foobar(name => "Foobar", -initargs => [1, 2, 3])
   # "init args: 1, 2, 3" was printed.
   $foo->{name} eq "Foobar";

   

=head1 DESCRIPTION

This is a base class for nearly every class in the Haver server,
and it is encouraged to be used for any class in the client, too.

The main advantage it brings is not having to write redundant
constructors, and also it prints debugging messages on object creation and destruction.

When a new object is instantiated, initialize() is called.
Don't overload DESTROY in child classes, use finalize() instead.

=head1 METHODS

=head2 $class->new(%options)

This constructor method creates and returns a new I<$class>,
initialized with the list of key-value pairs in I<%options>.
Keys that begin with _ are ignored. A special option
-initargs can be specified as an array reference,
and will be passed to initialize.


Alternatively, new() may be called
with as C<$class-E<gt>new($option, @initargs)>
where I<$option> is a hashref used like I<%options>
and I<@initargs> is a list of arguments to be passed to
initialize()

=head1 VIRTUAL METHODS

=head2 $self->initialize(@args)

This is called by new(), and should
be used to do any needed initialization things.
Optionally, I<@args> will contain arguments
passed to new(), as explained above.

In practice, no current subclass of Haver::Base
has an initalize method that takes arguments.

A subclass does not have to implement this method.

=head2 $self->finalize(Z<>)

This method is called from DESTROY().

You should overload this method instead of DESTROY(),
so that the useful debugging messages are printed
when objects are destroyed.

   
=head1 SEE ALSO

L<Haver::Singleton>

L<https://gna.org/projects/haver/>


=head1 AUTHOR

Dylan William Hardison, E<lt>dylanwh@tampabay.rr.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Dylan William Hardison

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
