# Haver::OS::Unix - routines and vars for a unix-like system.
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
package Haver::OS::Unix;
use strict;
use warnings;
use Carp;

use File::Path;
use File::Basename;

our $VERSION = 0.01;

sub current_user {
	$ENV{USER} || $ENV{LOGNAME} || getlogin || getpwuid($<);
}

sub config_find {
	my ($this, %arg) = @_;
	my $scope = $arg{scope} || 'user';
	my $type  = $arg{type}  || 'file';
	my $result;
	
	croak "name => 'appname' required" unless exists $arg{name};

	
	if ($scope eq 'global') {
		my $etc = $this->confdir;
		if ($type eq 'file') {
			$result = "$etc/$arg{name}rc";
		} elsif ($type eq 'dir') {
			$result = "$etc/$arg{name}";
		} else {
			croak "type => '$arg{type}' is an unknown type";
		}
	} elsif ($scope eq 'user' or $scope eq 'local') {
		my $home = $this->homedir;
		if ($type eq 'file') {
			$result = "$home/.$arg{name}rc";
		} elsif ($type eq 'dir') {
			$result = "$home/.$arg{name}";
		} else {
			croak "type => '$arg{type}' is an unknown type";
		}
	} elsif ($scope eq 'global-data') {
		$type = 'dir';
		$result = $this->datadir . "/$arg{name}";
	} else {
		croak "scope => '$arg{scope}' is an unknown scope";
	}


	$this->make_path(path => $result, type => $type) unless $arg{no_mkpath};

	
	return $result;

}

sub home { shift->homedir }
sub user_is_root { $> == 0 ? 1 : 0 }

sub family { 'Unix' }



sub confdir { '/etc'     }
sub homedir { $ENV{HOME} }
sub datadir { '/var/lib' }


1;
