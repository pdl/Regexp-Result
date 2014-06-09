package Regexp::Result;
use strict;
use warnings;
use Moo;
use 5.010; # we require ${^MATCH} etc
our $VERSION = '0.001';

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

1;

