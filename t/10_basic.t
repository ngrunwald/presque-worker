use strict;
use warnings;

use Test::More;

use presque::worker;

my $w = presque::worker->new_with_traits( { traits => [qw/foo/] } );
my $w2 = presque::worker->new();

ok 1;

done_testing;