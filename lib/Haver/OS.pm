# Haver::OS - Base class for operating-system specific things.
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
package Haver::OS;
use strict;
use warnings;
use File::Spec;
use File::Path ();
use File::Basename ();
use Carp;

our $VERSION = "0.01";

$VERSION = '0.87';

my $module = do {
	if ($^O eq 'linux') {
		'Linux';
	} elsif ($^O eq 'MSWin32') {
		require Win32;
		if (Win32::IsWinNT()) {
			'WinNT';
		} elsif (Win32::IsWin95()) {
			'Win95';
		}
	} elsif (lc($^O) eq /bsd/) {
		'BSD';
	} else {
		'Unix';
	}
};


require "Haver/OS/$module.pm";
our @ISA = ("Haver::OS::$module");

sub make_path {
	my ($this, %arg) = @_;
	my $path;
	
	if ($arg{type} eq 'file') {
		$path = File::Basename::dirname($arg{path});
	} elsif ($arg{type} eq 'dir') {
		$path = $arg{path};
	} else {
		croak "Unknown type: $arg{type}";
	}
	
	File::Path::mkpath($path);
}

sub type { $module }

sub user_is_root {
	undef;
}

1;

__END__

=head1 NAME

Haver::OS - Base class for operating-system specific routines.

=head1 SYNOPSIS

	use Haver::OS;
	
=head1 DESCRIPTION

This inherits from one of the Haver::OS::*
modules, depending on which system it is run on.
All operating system specific things that are not handled
by a standard perl module are handled in the Haver::OS::* modules.

=head1 METHODS

This an object oriented module.
All methods are called as C<Haver::OS-E<gt>methodname>.


=head2 type(Z<>)

Returns the type of operating system,
such as Linux, WinNT, Win95, BSD, or Unix.


=head2 family(Z<>)

Returns the family of the operating system,
this is either Unix or Windows currently.

=head2 user_is_root(Z<>)

Returns 1 if the operating system user
running this process is the root or admin user,
zero if not.

Returns undef if the OS doesn't have a concept of a root user.

=head2 current_user(Z<>)

Returns the login name of the user that is controling
this process or '' if the OS doesn't have the concept
of multiple users.

=head2 home(Z<>)

Returns the home directory
of the user that is controlling this process.

On Windows this will be the user's "My Documents" folder.

=head2 config_find(%Z<>args)

Finds a config file based on options given in %args.

Description of options follows.

=over 8

=item C<name>

This is the name of the application, such as 'haver-tk'.
This option is required.

=item C<type>

The type of config thing we want, either 'file' or 'dir'.
Defaults to 'file'.


=item C<scope>

The scope of the config file/dir. Can be
one of: global, user, local, or  global-data.

On Unix and Linux, global is stored in /etc/, while on BSD it is stored
in /etc/local/. In Windows, it is stored under program files.

user and local mean the same thing on all Unix systems (BSD, Linux, etc),
and that is $HOME. On Windows XPish, user config files/dirs will be part
of the user's roaming profile, while local will not be.

global-data is /var/lib on most Unix systems, while on Windows
it is mostly the same as global.

=back


=head1 SEE ALSO

L<File::Spec>, L<File::Path>, L<File::Basename>.

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
