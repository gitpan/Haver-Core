# Haver::Misc - Various routines
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
package Haver::Misc;
use strict;
#use warnings;
use Haver::Preprocessor;
use POSIX qw( strftime );
use Carp;
use Exporter;
use base 'Exporter';


our @EXPORT_OK = qw( format_datetime );
our $VERSION = '0.01';
our $RELOAD = 1;


sub format_datetime {
	# dylan: Because bd_ thought it should work this way...
	ASSERT: @_ <= 1;
	my $now = @_ ? shift : time;

	strftime('%Y-%m-%d %H:%M:%S %z', localtime($now));
}

sub parse_datetime {
	# FIXME
}

1;
