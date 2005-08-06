# vim: set ts=4 sw=4 si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Base;
use Spiffy qw( -Base );
use Carp;
use constant DEBUG => 1;

our $VERSION = 0.08;
our @EXPORT_BASE = qw( DEBUG field croak carp confess );

field 'factory';


BEGIN {
no warnings;
sub field(@) {
    use warnings;
    my $package = caller;

    if (DEBUG) {
    	my ($args, @values) = do {
        	no warnings;
        	local *boolean_arguments = sub { (qw( -weak -force )) };
        	local *paired_arguments = sub { (qw(  -package -init )) };
        	Haver::Base->parse_arguments(@_);
    	};
    	my ($field, $default) = @values;
    	if (my $sub = $package->can($field) and not $args->{'-force'}) {
        	require B;
        	my $p = B::svref_2object($sub)->START->stashpv;
        	if ($p ne $package) {
            	croak "Warning: redefining field $field in $package (Previously defined in $p)\n\t";
        	}
    	}
    }
    Spiffy::field (-package => $package, @_);}
}

sub new() {
    my $this = shift;
    my $self = super; 
    
    $self->initialize;
    
    return $self;
}

sub DESTROY {
    $self->finalize;
}

sub initialize { }
sub finalize   { }


