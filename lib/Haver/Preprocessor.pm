# Haver::Preprocessor - simple preprocessor for Haver scripts.
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
package Haver::Preprocessor;
use strict;
use warnings;
use Carp;

use Filter::Simple;
our ($ASSERT, $DUMP, $DEBUG, $VERBOSE);


FILTER {
	if ($ASSERT) {
		s/^\s*ASSERT:\s*(.+?);$/assert($1)/meg;
	} else {
		s/^\s*ASSERT:/# ASSERT:/mg;
	}
	
	if ($DUMP) {
		s/^\s*DUMP:\s*(.+?);$/dumper($1)/meg;
	} else {
		s/^\s*DUMP:/# DUMP:/mg;
	}
	
	if ($DEBUG) {
		s/^\s*DEBUG:\s*(.+?);\s*$/print STDERR $1, "\n";/mg;
	} else {
		s/^\s*DEBUG:/# DEBUG:/mg;
	}
};

if ($VERBOSE) {
	show("ASSERT = %s, DUMP = %s, DEBUG = %s\n",
		what($ASSERT), what($DUMP), what($DEBUG));
}

sub show {
	my $fmt = shift;
	print STDERR __PACKAGE__, ": ", sprintf($fmt, @_);
}

sub what {
	$_[0] ? 'enabled' : 'disabled'
}

sub assert {
	my $cond = shift;
	my $s = ' ' x 18;
	my $code = <<CODE;
unless ($cond) {no warnings;
Carp::confess (q{Assertion failed: ($cond) at },  __FILE__,  " line ", __LINE__, 
"\\n",qq{\\tDetails: "$cond"},"\\n");
}
CODE
	$code =~ s/\n//sg;
	return $code;
}

sub dumper {
	my $expr = shift;
	require Data::Dumper;
	return "warn Data::Dumper::Dumper($expr);";
}


1;
