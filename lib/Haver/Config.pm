# vim: set ts=4 sw=4 expandtab si ai sta tw=100:
# This module is copyrighted, see end of file for details.
package Haver::Config;
use strict;
use warnings;
use Haver::Base -base;
use Scalar::Util 'reftype';

use YAML ();
our $VERSION = 0.10;

field 'file';
field config  => {};


sub load {
    my ($self, $file) = @_;
    $self->file($file);
    my $config  = -e $file ? YAML::LoadFile($file) : {};
    $self->config($config);
    
    return 1;
}

sub reload {
    my $self = shift;
    my $file = $self->file;
    my $config  = -e $file ? YAML::LoadFile($file) : {};
    $self->config($config);
    
    return 1;
}

sub merge {
    my ($self, $hash) = @_;
    $self->config(_merge_hash($self->config, $hash));

    return 1;
}

sub save {
    my $self = shift;
    YAML::DumpFile($self->file, $self->config);
}

sub get {
    my ($self, $key) = @_;
    return $self->{config}{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    return $self->{config}{$key} = $val;
}

sub del {
    my ($self, $key) = @_;
    delete $self->{config}{$key};
}

sub AUTOLOAD {
    our $AUTOLOAD;
    my ($self)   = shift;
    my ($method) = $AUTOLOAD =~ /::(\w+)$/;
    return $self->{config}{$method};
}

# Author: bdonlan
sub _merge_struct ($$) {
	# ASSERT: @_ == 2;
	my ($left, $right) = @_;
	my $func = "_merge_struct(\$left,\$right):";
	
	unless (ref $left and ref $right) {
		return $left;
	}

	if (reftype $left ne reftype $right) {
		croak "$func \$left and \$right are not the same!";
	}
	if (reftype $left eq 'HASH') {
		goto &_merge_hash;
	} elsif (reftype $left eq 'ARRAY') {
		goto &_merge_array;
	} else {
		croak "$func Can not merge a(n) ", reftype $left, " reference!";
	}
}

# Author: bdonlan
sub _merge_hash ($$) {
	croak '_merge_hash($a,$b): $a and $b must be hashes!' 
        unless reftype($_[0]) eq 'HASH' and reftype($_[1]) eq 'HASH';
	my ($left, $right) = @_;
	my %merged = %$left;
	for (keys %$right) {
		if (exists $merged{$_}) {
			$merged{$_} = _merge_struct($merged{$_}, $right->{$_});
		} else {
			$merged{$_} = $right->{$_};
		}
	}
	return \%merged;
}

# Author: bdonlan
sub _merge_array ($$) {
    croak '_merge_array($a, $b): $a and $b must be arrays!'
        unless reftype($_[0]) eq 'ARRAY' and reftype($_[1]) eq 'ARRAY';
	my ($left, $right) = @_;
	return [@$left];
}

1;
__END__

=head1 NAME

Haver::Config - Configuration Manager.

=head1 SYNOPSIS

    use Haver::Config;
    my $ch = new Haver::Config (
        load  => "$ENV{HOME}/.myconfigfile",
        merge => {
            name => $ENV{USER},
            stuff => [1,2,3],
        },
    );
    my $config = $ch->config;
    $config->{name} eq $ENV{USER}; # true.
    $ch->save;
  
=head1 DESCRIPTION

This is a simple class to allow the loading and saving of config
files written in L<YAML> format.

In the future it might provide a way of finding config files in a cross-platform way
or even storing the config data in the Registry on Win32 platforms.

=head1 INHERITENCE

Haver::Config extends L<Haver::Base>.

=head1 METHODS

This class uses L<Spiffy> indirectly, and thus methods and parameters to the constructor new()
are the same thing. Thus you may write:

  $ch = new Haver::Config ( load => 'foobar' );

Instead of:

  $ch = new Haver::Config;
  $ch->load('foobar');

The following methods are public:

=head2 load($file)

Load the file $file into memory. This overwrites whatever config data is already loaded.

=head2 save(Z<>)

Save the config data to the most recently loaded file.

=head2 reload(Z<>)

Reload the most recently loaded file.

=head2 file(Z<>)

Return the name of the most recently loaded file.

=head2 merge($hash)

Recursively merge $hash with the loaded config data.
This should be called after load(). Already loaded data has precedence over $hash.

=head2 config(Z<>)

Return the currently loaded config data.

=head2 get($key)

This is shorthand for C<$self-E<gt>config-E<gt>{$key}>, except it is marginally faster
and perhaps safer to use.

=head2 set($key => $value)

Like get(), this is shorthand for C<$self-E<gt>config-E<gt>{$key} = $value>.

=head2 del($key)

Finally, this is shorthand for C<delete $self-E<gt>config-E<gt>{$key}>.

=head1 BUGS

None known. Bug reports are welcome. Please use our bug tracker at
L<http://gna.org/bugs/?func=additem&group=haver>.

=head1 AUTHOR

Dylan William Hardison, E<lt>dylan@haverdev.orgE<gt>
Bryan Donlan, E<lt>bdonlan@haverdev.orgE<gt>.

=head1 SEE ALSO

L<http://www.haverdev.org/>.

=head1 COPYRIGHT and LICENSE

Copyright 2005 by Dylan William Hardison. All Rights Reserved.
Copyright 2005 by Bryan Donlan. All Rights Reserved.

This module is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This module is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this module; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

