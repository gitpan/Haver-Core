# Haver::OS::WinNT - routines and vars for a Windows-NT based system.
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
package Haver::OS::WinNT;
use strict;
use warnings;

use Carp;
use Haver::OS::Win32;
use base 'Haver::OS::Win32';
use Win32;
use Win32::TieRegistry ( TiedRef => '$Reg', Delimiter => '/' );

our $VERSION = 0.01;
my %Dirs = ();

sub config_find {
	my ($this, %arg) = @_;
	my $scope = $arg{scope} || 'user';
	my $type  = $arg{type}  || 'file';
	my $result;
	
	croak "name => 'appname' required" unless exists $arg{name};

	my $name = join(' ', map ucfirst, split(/[-_ ]/, $arg{name}));
	my $programs = $this->program_files;
	
	if ($scope eq 'global') {		
		if ($type eq 'file') {
			$result = "$programs\\$name\\config.txt";
		} elsif ($type eq 'dir') {
			$result = "$programs\\$name";
		} else {
			croak "type => '$arg{type}' is an unknown type";
		}
	} elsif ($scope eq 'user') {
		my $dir = $Dirs{appdata};
		
		if ($type eq 'file') {
			$result = "$dir\\$name\\config.txt";
		} elsif ($type eq 'dir') {
			$result = "$dir\\$name";
		} else {
			croak "type => '$arg{type}' is an unknown type";
		}
	} elsif ($scope eq 'global-data') {
		if ($type eq 'file') {
			$result = "$programs\\$name\\data.dat";
		} elsif ($type eq 'dir') {
			$result = "$programs\\$name\\data";
		} else {
			croak "type => '$arg{type}' is an unknown type";
		}
	} else {
		croak "scope => '$arg{scope}' is an unknown scope";
	}

	
	$this->make_path(path => $result, type => $type) unless $arg{no_mkpath};
	return $result;
}


sub setup_dirs {
	return if %Dirs;
	
	my $usf = 'CUser/Software/Microsoft/Windows/CurrentVersion/Explorer/User Shell Folders/';
	my $f = $Reg->{$usf};

	$Dirs{personal}       = $f->{'/Personal'};
	$Dirs{appdata}       = $f->{'/AppData'};
	$Dirs{local_appdata} = $f->{'/Local AppData'};

	foreach my $key (keys %Dirs) {
		$Dirs{$key} = Win32::ExpandEnvironmentStrings($Dirs{$key});
	}
}

sub user_is_root {
	my $val = Win32::IsAdminUser();
	return 0 if not defined $val;
	return $val != 0 ? 1 : 0;
}

sub home {
	return $Dirs{personal};
}


setup_dirs();

1;
