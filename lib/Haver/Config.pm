# Haver::Config - Configuration Loader/Saver.
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
package Haver::Config;
use strict;
#use warnings;

use Haver::Savable;
use Haver::OS;

use base 'Haver::Savable';
use YAML ();
use Fatal qw(:void open close);
use File::stat;

use Haver::Preprocessor;

our $VERSION = '0.02';
our $RELOAD = 1;

sub initialize {
	my ($me) = @_;

	$me->SUPER::initialize;
	if (exists $me->{file}) {
		$me->filename(delete $me->{file});
	}

	if (exists $me->{default}) {
		$me->{_default} = delete $me->{default};
	}
	
	DEBUG: "Config file: ", $me->filename;
	if ($me->filename) {
		$me->load;
	}
}

sub _init_data {
	my ($me) = @_;
	my $h = delete $me->{_default};
	
	if ($h) {
		foreach my $key (keys %$h) {
			$me->{$key} = $h->{$key};
		}
	}
}

sub _load_data {
	my ($me, $data) = @_;
	ASSERT: ref($data) eq 'HASH' or UNIVERSAL::isa($data, 'HASH');

	foreach my $k (keys %$data) {
		$me->{$k} = $data->{$k};
	}
}

sub _save_data {
	my ($me) = @_;
	my %data = ();

	foreach my $k (keys %$me) {
		next if $k =~ /^_/;
		$data{$k} = $me->{$k};
	}

	return \%data;
}


sub load {
	my ($me, $fn) = @_;
	$me->filename($fn) if defined $fn;
	$me->SUPER::load;
}


sub filename {
	my ($me, $file) = @_;

	if (@_ == 1) {
		return $me->{_filename};
	} elsif (@_ == 2) {
		return $me->{_filename} = $file;
	}
		
}

1;

__END__

=head1 NAME

Haver::Config - Configuration manager.



=head1 SYNOPSIS

  use Haver::Config;
  my $config = new Haver::Config(file => 'some-file.yaml');
  

=head1 DESCRIPTION

 WRITE ME

=head1 INHERITANCE

Haver::Config

extends L<Haver::Savable>.

overloads C<initialize> C<load>, C<_save_data>, C<_load_data>.

FIXME

=head1 SEE ALSO

L<https://savannah.nongnu.org/projects/haver/>



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
