
use strict;
use warnings;

#use Collision::Util ':all';
use Collision::Util::Dynamic ':all';

use Test::More tests => 5;

my $andy = hash2rect {x=>0, y=>0, h=>14, w=>3};
my $bullet1 = hash2point { x=>-50, y=>10, xv=>100, yv=>16 }; #miss
my $bullet2 = hash2point { x=>-50, y=>10, xv=>100, yv=>0 }; #hit
#Bless you, Andy. Blandy.

my $collision1 = dynamic_collision ($bullet1, $andy, interval=>1);
my $collision2 = dynamic_collision ($bullet2, $andy, interval=>1);

ok (!defined $collision1);
isa_ok ($collision2, 'Collision::Util::Collision');
is ($collision2->axis, 'x', 'horizontal collision. should axis of collision be a vector?');
is ($collision2->time, .5, 'bullet hits andy in half of a time unit');


my $grid_environment = Collision::Util::Grid->new (file => 'level1.txt');

#let's say andy doesn't intersect any blocks in this environment.
ok (!dynamic_collision($andy, $grid_environment));

#but this bullet hits a block in 1st frame or second.
my $collision3 = dynamic_collision ($bullet1, $grid_environment, interval=>1);




