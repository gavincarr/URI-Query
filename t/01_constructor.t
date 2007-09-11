# Basic URI::Query tests

use Test::More tests => 17;
use_ok(URI::Query);
use strict;

my $qq;

# Constructor - scalar version
ok($qq = URI::Query->new('foo=1&foo=2&bar=3;bog=abc;bar=7;fluffy=3'), "constructor1 ok");
is($qq->stringify, 'bar=3&bar=7&bog=abc&fluffy=3&foo=1&foo=2', 
  sprintf("stringifies ok (%s)", $qq->stringify));

# Constructor - array version
ok($qq = URI::Query->new(foo => 1, foo => 2, bar => 3, bog => 'abc', bar => 7, fluffy => 3), "array constructor ok");
is($qq->stringify, 'bar=3&bar=7&bog=abc&fluffy=3&foo=1&foo=2', 
  sprintf("stringifies ok (%s)", $qq->stringify));

# Constructor - hashref version
ok($qq = URI::Query->new({ foo => [ 1, 2 ], bar => [ 3, 7 ], bog => 'abc', fluffy => 3 }), "hashref constructor ok");
is($qq->stringify, 'bar=3&bar=7&bog=abc&fluffy=3&foo=1&foo=2', 
  sprintf("stringifies ok (%s)", $qq->stringify));

# Bad constructor args
for my $bad ((undef, '', \"foo", [ foo => 1 ], \*bad)) {
  my $b2 = $bad;
  $b2 = '[undef]' unless defined $bad;
  $qq = URI::Query->new($bad);
  ok(ref $qq eq 'URI::Query', "bad '$b2' constructor ok");
  is($qq->stringify, '', sprintf("stringifies ok (%s)", $qq->stringify));
}

# arch-tag: 714ab082-385f-4158-bbf5-7547759ec65e
