# Haver::Savable - Saver/Loader
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
package Haver::Savable;
use strict;
#use warnings;
use base 'Haver::Base';
use YAML ();
use Fatal qw(:void open close);
use File::stat ();
use File::Basename ();
use File::Path ();

use Haver::Preprocessor;
use Carp;

our $VERSION = '0.02';
our $RELOAD = 1;

sub initialize {
	my ($me) = @_;

	$me->{_mtime}      = -1;
	$me->{_overwrite} = 0;
}

sub load {
	my ($me) = @_;
	my $filename = $me->filename;
	my $fh;

	DEBUG: "Loading $me";
	ASSERT: defined $filename;
	if (-e $filename) {
		local $/ = undef;
		open $fh, $filename;
		my $raw  = readline $fh; # slurp in file
		my $data = YAML::Load($raw);
		close $fh;
		$me->{_mtime} = File::stat::populate(CORE::stat(_))->mtime;
		return $me->_load_data($data);
	} else {
		$me->{_mtime} = time;
		$me->_init_data;
		return undef;
	}

}

sub _init_data {
}

sub save {
	my ($me) = @_;
	my $filename = $me->filename;
	my $fh;

	ASSERT: defined $filename;
	my $mtime = do {
		if (-e $filename) {
			File::stat::populate(CORE::stat(_))->mtime;
		} else {
			$me->{_mtime};
		}
	};
	ASSERT: defined $mtime;

	File::Path::mkpath($me->directory);
	
	if ($me->{_overwrite} or ($mtime == $me->{_mtime})) {
		my $fh;
		my $save = $me->_save_data or return 0;
		open $fh, ">$filename";
		print $fh YAML::Dump($save);
		close $fh;
		$me->{_mtime} = File::stat::stat($filename)->mtime;
		DEBUG: "Saving $me";
		return 1;
	} else {
		carp "Cowardly refusing to overwrite $filename... $mtime != $me->{_mtime}";
		return 0;
	}	
}

sub overwrite {
	my ($me, $val) = @_;
	ASSERT: @_ == 1 or @_ == 2;

	if (@_ == 1) {
		return $me->{_overwrite};
	} elsif (@_ == 2) {
		return $me->{_overwrite} = $val;
	}
}

sub directory {
	my ($me) = @_;

	(File::Basename::fileparse($me->filename))[1];
}

sub finalize {
	my ($me) = @_;


}


1;

__END__

=head1 NAME

Haver::Savable - Framework for persistent objects.

=head1 SYNOPSIS

 # See the source code for Haver::Config.

=head1 DESCRIPTION

Haver::Savable is a base class for objects that need to have persistency,
such as config files. Haver::Savable is only a base class, you need
to inherit from it in order to use it.


=head1 METHODS

=head2 new(Z<>)

the new() constructor creates and returns a new Haver::Savable.
It takes no options.


=head2 save(Z<>)

This saves data to C<$self-E<gt>filename()>. It takes no arguments.
The data to be saved is obtained by calling C<$self-E<gt>_save_data()>.
=head2 load(Z<>)

This loads data from C<$self-E<gt>filename()>
and passes it to C<$self-E<gt>_load_data()>.

=head2 auto_save($bool)

This gets or sets the auto_save option. If auto_save is true,
then C<$self-E<gt>save()> will be called upon object destruction.

The default is false.

=head2 overwrite($bool)

This gets or sets the overwrite option. If overwrite
is false, when you go to save() a savable object,
it will cowardly refuse to overwrite C<$self-E<gt>filename>.

If overwrite is true, then it will always save over
the file, even if the file has been modified since
the last load().

The default is false.

=head1 VIRTUAL METHODS

These methods you must define in your subclasses (except
for the optional one).

=head2 _init_data(Z<>)

This is optional. If defined, it will be called when
C<$self-E<gt>filename()> can not be found. It should probably
set up default values that will later be saved to C<$self-E<gt>filename()>.

=head2 _load_data($data)

This method should take whatever is in $data and load it into $self
somehow. The type of $data is application-dependant; generally
it is whatever C<$self-E<gt>_save_data()> returns (see below).

=head2 _save_data(Z<>)

This method should inspect $self and return whatever
should be written (serialized) to C<$self-E<gt>filename()>.

=head1 SEE ALSO

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
