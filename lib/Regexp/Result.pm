package Regexp::Result;
use strict;
use warnings;
use Moo;
use 5.010; # we require ${^MATCH} etc
our $VERSION = '0.001';

=head1 NAME

Regexp::Result - store information about a regexp match for later retrieval

=head1 SYNOPSIS

	$foo =~ /(a|an|the) (\w+)/;
	my $result = Regexp::Result->new();

	# some other code which potentially executes a regular expression

	my $determiner = $result->c(1); # i.e. $1 at the time when the object was created

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

has match =>
	is => 'ro',
	default => sub{
	   ${^MATCH}
	};

has prematch =>
	is => 'ro',
	default => sub{
	   ${^PREMATCH}
	};

has postmatch =>
	is => 'ro',
	default => sub{
	   ${^POSTMATCH}
	};

has last_paren_match =>
	is => 'ro',
	default => sub{
	   $+;
	};

has last_submatch_result =>
	is => 'ro',
	default => sub{
	   $^N;
	};
# these are all a bit odd in the docs
has last_numbered_match_end =>
	is => 'ro',
	default => sub{
	   [@+]
	};

has last_named_paren_match =>
	is => 'ro',
	default => sub{
	   {%+}
	};

has last_numbered_match_start =>
	is => 'ro',
	default => sub{
	   [@-]
	};

has last_regexp_code_result =>
	is => 'ro',
	default => sub{
	   $^R;
	};

has re_debug_flags =>
	is => 'ro',
	default => sub{
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

