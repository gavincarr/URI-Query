#
# Class providing URI query string manipulation
#

package URI::Query;

use 5.00503;
use URI::Escape;
use strict;
use overload 
  '""'    => \&stringify,
  'eq'  => sub { $_[0]->stringify eq $_[1]->stringify },
  'ne'  => sub { $_[0]->stringify ne $_[1]->stringify };
use vars q($VERSION);

$VERSION = '0.06';

# -------------------------------------------------------------------------
# Remove all occurrences of the given parameters
sub strip
{
    my $self = shift;
    delete $self->{qq}->{$_} foreach @_;
    $self
}

# Remove all parameters except those given
sub strip_except
{
    my $self = shift;
    my %keep = map { $_ => 1 } @_;
    foreach (keys %{$self->{qq}}) {
        delete $self->{qq}->{$_} unless $keep{$_};
    }
    $self
}

# Remove all empty/undefined parameters
sub strip_null
{
    my $self = shift;
    foreach (keys %{$self->{qq}}) {
        delete $self->{qq}->{$_} unless @{$self->{qq}->{$_}};
    }
    $self
}

# Replace all occurrences of the given parameters
sub replace
{
    my $self = shift;
    my %arg = @_;
    for my $key (keys %arg) {
        $self->{qq}->{$key} = [];
        if (ref $arg{$key} eq 'ARRAY') {
            push @{$self->{qq}->{$key}}, $_ foreach @{$arg{$key}};
        }
        else {
            push @{$self->{qq}->{$key}}, $arg{$key};
        }
    }
    $self
}

# Return the stringified qq hash
sub stringify
{
    my $self = shift;
    my $sep = shift || $self->{sep} || '&';
    my @out = ();
    for my $key (sort keys %{$self->{qq}}) {
        for my $value (sort @{$self->{qq}->{$key}}) {
            push @out, sprintf("%s=%s", uri_escape($key), uri_escape($value));
        }
    }
    join $sep, @out;
}

sub revert
{
    my $self = shift;
    # Revert qq to the qq_orig hashref
    $self->{qq} = $self->deepcopy($self->{qq_orig});
    $self
}

# -------------------------------------------------------------------------
# Convenience methods

# Return the current qq hash(ref) with one-elt arrays flattened
sub hash
{
    my $self = shift;
    my %qq = %{$self->{qq}};
    # Flatten one element arrays
    for (sort keys %qq) {
      $qq{$_} = $qq{$_}->[0] if @{$qq{$_}} == 1;
    }
    return wantarray ? %qq : \%qq;
}

# Return the current qq hash(ref) with all elements as arrayrefs
sub hash_arrayref
{
    my $self = shift;
    my %qq = %{$self->{qq}};
    # (Don't flatten one element arrays)
    return wantarray ? %qq : \%qq;
}

# Return the current query as a string of html hidden input tags
sub hidden 
{
    my $self = shift;
    my $str = '';
    for my $key (sort keys %{$self->{qq}}) {
        for my $value (@{$self->{qq}->{$key}}) {
            $str .= qq(<input type="hidden" name="$key" value="$value" />\n);
        } 
    }
    return $str;
}

# -------------------------------------------------------------------------
# Parse query string, storing as hash (qq) of key => arrayref pairs
sub parse_qs
{
    my $self = shift;
    my $qs = shift;
    for (split /&/, $qs) {
        my ($key, $value) = split /=/;
        $self->{qq}->{$key} ||= [];
        push @{$self->{qq}->{$key}}, $value if defined $value && $value ne '';
    }
    $self
}

# Deep copy routine, originally swiped from a Randal Schwartz column
sub deepcopy 
{
    my ($self, $this) = @_;
    if (! ref $this) {
        return $this;
    } elsif (ref $this eq "ARRAY") {
        return [map $self->deepcopy($_), @$this];
    } elsif (ref $this eq "HASH") {
        return {map { $_ => $self->deepcopy($this->{$_}) } keys %$this};
    } elsif (ref $this eq "CODE") {
        return $this;
    } elsif (sprintf $this) {
        # Object! As a last resort, try copying the stringification value
        return sprintf $this;
    } else {
        die "what type is $_? (" . ref($this) . ")";
    }
}

# Set the output separator to use by default
sub separator
{
    my $self = shift;
    $self->{sep} = shift;
}

# Constructor - either new($qs) where $qs is a scalar query string or a 
#   a hashref of key => value pairs, or new(key => val, key => val);
#   In the array form, keys can repeat, and/or values can be arrayrefs.
sub new
{
    my $class = shift;
    my $self = bless { qq => {} }, $class;
    if (@_ == 1 && ! ref $_[0] && $_[0]) {
        my $qs = shift || '';
        # Standardise arg separator
        $qs =~ s/;/&/g;
        $self->parse_qs($qs);
    }
    elsif (@_ == 1 && ref $_[0] eq 'HASH') {
        for my $key (keys %{$_[0]}) {
            $self->{qq}->{$key} ||= [];
            my $value = $_[0]->{$key};
            push @{$self->{qq}->{$key}}, (ref $value eq 'ARRAY' ? @$value : $value)
                if defined $value && $value ne '';
        }
    }
    else {
        while (@_ >= 2) {
            my $key = shift;
            my $value = shift;
            $self->{qq}->{$key} ||= [];
            push @{$self->{qq}->{$key}}, (ref $value eq 'ARRAY' ? @$value : $value)
                if defined $value && $value ne '';
        }
    }
    # Clone the qq hashref to allow reversion 
    $self->{qq_orig} = $self->deepcopy($self->{qq});
    return $self;
}
# -------------------------------------------------------------------------

1;

=head1 NAME

URI::Query - class providing URI query string manipulation

=head1 SYNOPSIS

    # Constructor - using a GET query string
    $qq = URI::Query->new($query_string);
    # OR Constructor - using a set of key => value parameters 
    $qq = URI::Query->new(%Vars);

    # Remove all occurrences of the given parameters
    $qq->strip('page', 'next');

    # Remove all parameters except the given ones
    $qq->strip_except('pagesize', 'order');

    # Remove all empty/undefined parameters
    $qq->strip_null;

    # Replace all occurrences of the given parameters
    $qq->replace(page => $page, foo => 'bar');

    # Set the argument separator to use for output (default: unescaped '&')
    $qq->separator(';');

    # Output the current query string
    print "$qq";           # OR $qq->stringify;
    # Stringify with explicit argument separator
    $qq->stringify(';');

    # Get a flattened hash/hashref of the current parameters
    #   (single item parameters as scalars, multiples as an arrayref)
    my %qq = $qq->hash;

    # Get a non-flattened hash/hashref of the current parameters
    #   (parameter => arrayref of values)
    my %qq = $qq->hash_arrayref;

    # Get the current query string as a set of hidden input tags
    print $qq->hidden;

    # Revert back to the initial constructor state (to do it all again)
    $qq->revert;


=head1 DESCRIPTION

URI::Query provides simple URI query string manipulation, allowing you
to create and manipulate URI query strings from GET and POST requests in
web applications. This is primarily useful for creating links where you 
wish to preserve some subset of the parameters to the current request,
and potentially add or replace others. Given a query string this is 
doable with regexes, of course, but making sure you get the anchoring 
and escaping right is tedious and error-prone - this module is simpler.


=head1 BUGS AND CAVEATS

None known.

Note that this module doesn't do any input unescaping of query strings - 
you're (currently) expected to handle that explicitly yourself.


=head1 AUTHOR

Gavin Carr <gavin@openfusion.com.au>


=head1 COPYRIGHT

Copyright 2004-2005, Gavin Carr. All Rights Reserved.

This program is free software. You may copy or redistribute it under the 
same terms as perl itself.


=cut

# arch-tag: 66eb6ee6-02bb-43e5-bda7-9529ad44f86f

