# Haver::OS::Win32 - routines and vars for a Windows system
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
package Haver::OS::Win32;
use strict;
use warnings;

our $VERSION = 0.01;
use Win32;
use Win32::TieRegistry (TiedRef => '$WinReg');

sub current_user {
	Win32::LoginName();
}

{
	my $progdir;
	sub program_files {
		return $progdir if defined $progdir;
		$progdir = $WinReg->{
			'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows'
			. '\CurrentVersion\ProgramFilesDir'
		};
	}
}


sub family { 'Windows' }


1;
