# Haver::Logger - Logger
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
package Haver::Logger;
use strict;
use warnings;

use POE qw( Wheel::ReadWrite Driver::SysRW Filter::Line );
use Fatal qw( :void open close );

use Haver::Preprocessor;

our $VERSION = "0.01";
my $Package = __PACKAGE__;

sub create {
	my $class = shift;
	ASSERT: (@_ == 1) or ((@_ % 2) == 0);
	my $opts = @_ == 1 ? $_[0] : { @_ };

	create POE::Session (
		package_states => [
			$Package => {
				_start     => 'on_start',
				_stop      => 'on_stop',
				_default   => 'on_default',
                'shutdown' => 'on_shutdown',
                'flush'    => 'on_flush',
			},
		],
		args => [ $opts ],
        heap => { 
            alias => 'Logger' || delete $opts->{alias},
        },
	);
}

sub on_start {
	my ($kernel, $heap, $opts) = @_[KERNEL, HEAP, ARG0];
	my %wheels  = ();
	my @handles = ();
	my $levels  = $opts->{levels};
	my $driver  = $opts->{driver} || sub { new POE::Driver::SysRW };
	my $filter  = $opts->{filter} || sub { new POE::Filter::Line(OutputLiteral => "\n") };

	
	foreach my $level (keys %$levels) {
		my $file = $opts->{levels}{$level};
		my $fh;
		unless (ref $file) {
			open $fh, ">$file";
		} else {
			$fh = $file;
		}
		
		$wheels{$level} = new POE::Wheel::ReadWrite (
			InputHandle  => -1,
			OutputHandle => $fh,
			Driver       => $driver->(),
			Filter       => $filter->(),
            FlushedEvent   => 'flush',
		);
	}

	$heap->{wheels} = \%wheels;

	$kernel->alias_set($heap->{alias});
	print "Logger starts.\n";
}

sub on_stop {
	print "Logger stops.\n";
}

sub on_default {
	my ($kernel, $heap, $level, $args) = @_[KERNEL, HEAP, ARG0, ARG1];
	my $msg = $args->[0];

	if ($level =~ /^_/) {
		return 0;
	}
	
	if (exists $heap->{wheels}{$level}) {
		$heap->{wheels}{$level}->put($msg);
    } elsif (exists $heap->{wheels}{default}) {
        $heap->{wheels}{default}->put($msg);
	} else {
		print "[$level] $msg\n";
	}

}

sub on_shutdown {
    my ($kernel, $heap) = @_[KERNEL, HEAP];

    $kernel->alias_remove($heap->{alias});
    $heap->{shutdown} = 1;
}

sub on_flush {
	my ($kernel, $heap) = @_[KERNEL, HEAP];
	
    if ($heap->{shutdown}) {
        $heap->{wheels} = {};
    }
}

1;

__END__

=head1 NAME

Haver::Logger - POE-based logging service.

=head1 SYNOPSIS
   
   use Haver::Logger;
   create Haver::Logger (
      levels => {
         alert => 'alert.log',
         error => \*STDERR,
         foo   => new IO::File ('bunnies.log'),
      },
      filter => sub { new POE::Filter::Line },  # optional, default
      driver => sub { new POE::Driver::SysRW }, # optional, default
      alias  => 'Logger' # optional, default
   );

   # in some POE-state,
   $kernel->post('Logger', 'alert', 'bunnies');
   $kernel->post('Logger', 'error', 'I have been stolen by aliens');
   $kernel->post('Logger', 'foo', 'bar baz <g>');

   # When you're done:
   $kernel->post('Logger', 'shutdown');


=head1 DESCRIPTION

FIXME: Document this.

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
