
use strict;
use warnings;

use Collision::Util ':all';

use Test::More tests => 5;

my $tom = {x=>0, y=>0, h=>14, w=>3};
my $bullet1 = { x=>-50, y=>10, hv=>100, vv=>16 }; #miss
my $bullet2 = { x=>-50, y=>10, hv=>100, vv=>0 }; #hit
bless $tom;

my $collision1 = dynamic_collision ($bullet1, $tom, interval=>1);
my $collision2 = dynamic_collision ($bullet2, $tom, interval=>1);

ok (!defined $collision1);
isa_ok ($collision2, 'Collision::Util::Collision');
is ($collision2->axis, 'x', 'horizontal collision. should axis of collision be a vector?');
is ($collision2->t, .5, 'bullet hits tom in half of a time unit');


my $grid_environment = Collision::Util::Grid->new (file => 'level1.txt');

#let's say tom doesn't intersect any blocks in this environment.
nok (check_contains($tom, $grid_environment));

#but this bullet hits a block in 1st frame or second.
my $collision3 = dynamic_collision ($bullet1, $grid_environment, interval=>1);
