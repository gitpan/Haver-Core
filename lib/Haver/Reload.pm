# Haver::Reload - Reload modules.
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
package Haver::Reload;
use strict;
use warnings;
use File::stat;

our $VERSION = '0.01';
our %Stat;
our $Pattern = qr/^Haver::/;
our $RELOAD = 1;

sub init {
	foreach my $key (keys %INC) {
		my $mod = $key;
		$mod =~ s!/!::!g;
		$mod =~ s/\.pm$//;
		unless ($mod =~ $Pattern) {
			next;
		}
		$Stat{$key} = stat($INC{$key})->mtime;
	}
}

sub pattern {
	my ($this, $pat) = @_;
	if (ref($pat) eq 'Regexp') {
		$Pattern = $pat;
	}
}

sub load {
	my ($this, $mod) = @_;
	my $file = $mod;
	$file =~ s!::!/!g;
	$file .= '.pm';
	eval {
		require $file;
	};
	if ($@) {
		warn "Error loading ${mod}: $@";
		return 0;
	} else {
		$Stat{$file} = stat($INC{$file})->mtime;
		return 1;
	}
}

sub reload {
	my %mods;
	my $mtime;
	my @did;
	
	while (my ($key, $file) = each %INC) {
		my $file = $INC{$key};
		my $mod = $key;
		$mod =~ s!/!::!g;
		$mod =~ s/\.pm$//;

		unless ($mod =~ $Pattern) {
			next;
		}
		
		$mtime = stat($file)->mtime;
		no strict 'refs';
		unless (defined ${"${mod}::RELOAD"}) {
			print "\$${mod}::RELOAD is not set\n";
			next;
		}
		use strict 'refs';
		
		if ($mtime > $Stat{$key}) {
			local $^W = 0;
			push(@did, $mod);
			delete $INC{$key};
			eval {
				require $key;
			};
			if ($@) {
				warn "Error reloading ${mod}: $@";
				$INC{$key} = $file;
			} else {
				if (my $code = $mod->can('RELOAD')) {
					eval { $code->($mod) };
				}
			}
		}
	} continue {
		if (defined $mtime) {
			$Stat{$key} = $mtime;
		}
		$mtime = undef;
	}

	return @did;
}

1;
__END__

=head1 NAME

Haver::Reload - Reload modules if needed

=head1 SYNOPSIS

  use Haver::Reload;
  Haver::Reload->init;

  # Now, reload things:
  my @did = Haver::Reload->reload;

  # @did is a list of modules we reloaded.
 
  # change the default module matching pattern:
  Haver::Reload->pattern(qr/^MyMod::/);

  # Try to load a module at run-time:
  if (Haver::Reload->load('Haver::Server::Monkey')) {
    print "OK!\n";
  } else {
    print "Can't load Haver::Server::Monkey!\n";
  }
  # Note, the above is probably always going to be used as a way
  # to force-reload something.
  
  

=head1 DESCRIPTION

This module reloads modules, if the module is reloadable and has changed
since init() was last called. The module must also match $Haver::Reload::Pattern,
which is a regexp thingy, made with qr//. 
A module is considered reloadable if it contains a package global scalar
$RELOAD and if that said global is true.

$Haver::Reload::Pattern defaults to qr/^Haver::/.

=head2 EXPORTS

Nothing at all.

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
