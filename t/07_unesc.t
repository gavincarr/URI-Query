# Test input unescaping
# 
# Fixing bug #35170: https://rt.cpan.org/Public/Bug/Display.html?id=35170
#
# RFC2396: Within a query component, the characters ";", "/", "?", 
#    ":", "@", "&", "=", "+", ",", and "$" are reserved.
#

use strict;
use Test::More;
BEGIN { use_ok( 'URI::Query' ) }

my $qq;

ok($qq = URI::Query->new('group=prod%2Cinfra%2Ctest&op%3Aset=x%3Dy'), 'qq constructor ok');
is_deeply(scalar $qq->hash, {
  group     => 'prod,infra,test',
  'op:set'  => 'x=y',
}, '$qq->hash keys and values are unescaped');
is("$qq", 'group=prod%2Cinfra%2Ctest&op%3Aset=x%3Dy', 'stringified keys/values escaped ok');

done_testing;

