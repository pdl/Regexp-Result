package Regexp::Result;
use strict;
use warnings;
use Moo;
use 5.010; # we require ${^MATCH} etc
our $VERSION = '0.001';
use Sub::Name 'subname';

=head1 NAME

Regexp::Result - store information about a regexp match for later retrieval

=head1 SYNOPSIS

	$foo =~ /(a|an|the) (\w+)/;
	my $result = Regexp::Result->new();

	# some other code which potentially executes a regular expression

	my $determiner = $result->c(1); # i.e. $1 at the time when the object was created

Have you ever wanted to retain information about a regular expression match, without having to go through the palaver of pulling things out of C<$1>, C<pos>, etc. and assigning them each to temporary variables until you've decided what to use them as?

Regexp::Result objects, when created, contain as much information about a match as perl can tell you. This means that you just need to create one variable and keep it.

Hopefully, your code will be more comprehensible when it looks like C<< $result->last_numbered_match_start->[-1] >>instead of C<$-[-1]>. And unlike the punctuation variables, which are hidden away in C<perldoc perlvar> along with scary notation like C<$^H>, they are^H^H^H will be documented here, eventually with some realistic use cases.

=cut

has numbered_captures=>
	is => 'ro',
	default => sub{
	    my $captures = [];
	    my $i = 1;
	    no strict 'refs';
	    while (defined ${$i}) {
		push @$captures, ${$i};
		$i++;
	    }
	    use strict 'refs';
	    $captures;
	};

sub c {
    my ($self, $number) = @_;
    if ($number) {
	return $self->numbered_captures->[$number - 1];
    }
    return undef;
}

sub _has_scalar {
	my ($name, $creator) = @_;
	has $name =>
		is => 'ro',
		default => $creator
}

#~ _has_array
#~
#~ 	_has_array primes => sub { [2,3,5,7,11] };
#~	$object->primes->[0]; # 2
#~	$object->primes(0);   # also 2


sub _has_array {
	my ($name, $creator) = @_;
	my $realName = '_'.$name;
	has $realName =>
		is => 'ro',
		default => $creator;
	my $accessor = sub {
		my $self = shift;
		if (@_) {
			#~ ideally check if @_ contains only numbers
			#~ Should foo(1,3) return something different?
			return $self->$realName->[@_];
		}
		else {
			return $self->$realName;
		}
	};
	{
		my $package = __PACKAGE__;
                no strict 'refs';
                my $fullName = $package . '::' . $name;
                *$fullName = subname( $name, $accessor );
        }
}

sub _has_hash {
	my ($name, $creator) = @_;
	my $realName = '_'.$name;
	has $realName =>
		is => 'ro',
		default => $creator;
	my $accessor = sub {
		my $self = shift;
		if (@_) {
			return $self->$realName->{@_};
		}
		else {
			return $self->$realName;
		}
	};
	{
		my $package = __PACKAGE__;
                no strict 'refs';
                my $fullName = $package . '::' . $name;
                *$fullName = subname( $name, $accessor );
        }
}

_has_scalar match => sub{
	   ${^MATCH}
	};

_has_scalar prematch => sub{
	   ${^PREMATCH}
	};

_has_scalar postmatch => sub{
	   ${^POSTMATCH}
	};

_has_scalar last_paren_match => sub{
	   $+;
	};

_has_scalar last_submatch_result => sub{
	   $^N;
	};
# these are all a bit odd in the docs
_has_array last_numbered_match_end => sub{
	   [@+]
	};

_has_hash last_named_paren_match => sub{
	   {%+}
	};

_has_array last_numbered_match_start => sub{
	   [@-]
	};

_has_hash last_named_paren_match_start => sub{
	   {%-}
	};

_has_scalar last_regexp_code_result => sub{
	   $^R;
	};

_has_scalar re_debug_flags => sub{
	   ${^RE_DEBUG_FLAGS}
	};

sub pos {
    return shift->last_match_end->[0];
}

=head1 BUGS

Please report any bugs or feature requests to the github issues tracker at L<https://github.com/pdl/Regexp-Result/issues>. I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 AUTHORS

Daniel Perrett

=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Daniel Perrett.

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as published by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;

