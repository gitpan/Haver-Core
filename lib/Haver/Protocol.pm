# Haver::Protocol, Right now this
# just loads Haver::Protocol::* modules.
# 
# Copyright (C) 2003 Dylan William Hardison
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

package Haver::Protocol;
use strict;
use warnings;

use Exporter;
use base 'Exporter';

BEGIN {
	our @EXPORT    = ();
	our @EXPORT_OK = qw(
		escape unescape
		event2line line2event
		$CRLF $CR $LF
		%Escape
		%Unescape
	);
	our %EXPORT_TAGS = (
		all    => [@EXPORT_OK],
		escape => [qw( escape unescape )],
		event  => [qw( event2line line2event )],
		crlf   => [qw( $CR $LF $CRLF )],
	);
}

our $VERSION   = "0.03";
our $CRLF      = "\x0D\x0A";
our $CR        = "\x0D";
our $LF        = "\x0A";
our %Escape = (
	$CR    => 'r',
	$LF    => 'n',
	"\e"   => 'e',
	"\t"   => 't',
);
our %Unescape = reverse %Escape;

my $Chars = join('', keys %Escape);
my $Codes = join('', keys %Unescape);

sub escape {
	my ($s) = @_;
	$s =~ s/([$Chars])/\e$Escape{$1}/g;
	return $s;
}

sub unescape {
	my ($s) = @_;
	$s =~ s/\e([$Codes])/$Unescape{$1}/g;
	return $s;
}

sub line2event {
	my ($line) = @_;
	$line =~ s/$CRLF$//g;
	my @e = split("\t", $line);
	foreach (@e) {
		$_ = unescape($_);
	}
	
	return wantarray ? @e : \@e;
}

sub event2line {
	my @event;
	if (@_ > 1) {
		@event = @_;
	} else {
		@event = @{$_[0]};
	}
	foreach (@event) {
		$_ = escape($_);
	}
	
	join("\t", @event) . $CRLF;
}


1;

1;
__END__

=head1 NAME

Haver::Protocol - Routines for parsing the haver protocol.

=head1 SYNOPSIS

  use Haver::Protocol;

=head1 DESCRIPTION

Currently this just loads Haver::Protocol::Filter. In the future,
when/if there are more protocol-related modules, it'll load them too.

=head2 EXPORT

Nothing to export.

Can export escape(), unescape(),
event2line(), line2event(), $CRLF, $CR, $LF, %Escape, %Unescape.

=head1 SEE ALSO

L<Haver::Protocol::Filter>

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
