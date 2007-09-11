# Test 'eq' overloading

use Test::More tests => 8;
BEGIN { use_ok( URI::Query ) }
use strict;
my ($qq1, $qq2);

ok($qq1 = URI::Query->new('foo=1&foo=2&bar=3'), 'qq1 constructor ok');
ok($qq2 = URI::Query->new('foo=1&foo=2&bar=3'), 'qq2 constructor ok');
is($qq1, $qq2, 'eq ok');
ok($qq2 = URI::Query->new('bar=3&foo=2&foo=1'), 'qq2 constructor ok');
is($qq1, $qq2, 'eq ok');
ok($qq2 = URI::Query->new('bar=3'), 'qq2 constructor ok');
isnt($qq1, $qq2, 'ne ok');


# arch-tag: 0fa9697e-843a-4cd3-a4d5-c4aac67430a0
