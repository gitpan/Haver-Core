# Haver::Singleton
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
package Haver::Singleton;
use strict;
use warnings;

our $VERSION = '0.03';
use base 'Haver::Base';

sub new {
	die "Never call 'new' on a singleton class! ($_[0])"
}
sub _new_instance {
	my $this = shift;
	return $this->SUPER::new(@_);
}
sub instance {
	my $this = shift;
	my $class = ref($this) || $this;

	no strict 'refs';
	my $self = "${class}::__INSTANCE__";
	
	
	if (${$self}) {
		return ${$self};
	} else {
		return ${$self} = $this->_new_instance(@_);
	}

}
1;
__END__

=head1 NAME

Haver::Singleton - Base class for singleton classes.

=head1 SYNOPSIS

  use Haver::Singleton (@args);
  my $one = instance Haver::Singleton (@args);
  my $another = instance Haver::Singleton (@args); # Same as $one.

=head1 DESCRIPTION

This is the base class for all singleton objects in Haver server and the haver clients.
It is derived from Haver::Base.

TODO: document methods, explain what a singleton object is, explain
how import() is used for default arguments to instance(). Explain instance(),
and how/why new() is not to be used.

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
