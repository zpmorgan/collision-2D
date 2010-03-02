
use strict;
use warnings;

#use Collision::Util ':all';
use Collision::Util::Dynamic ':all';

use Test::More tests => 23;

{
   my $andy = hash2rect {x=>-1, y=>-1, h=>2, w=>2};
   my $bullet1 = hash2point { x=>-51, y=>0, xv=>100, yv=>16 }; #wild miss
   my $bullet2 = hash2point { x=>-51, y=>0, xv=>100, yv=>0 }; #hit
   #Bless you, Andy. Blandy.

   my $collision1 = dynamic_collision ($bullet1, $andy, interval=>1);
   my $collision2 = dynamic_collision ($bullet2, $andy, interval=>1);

   ok (!defined $collision1);
   isa_ok ($collision2, 'Collision::Util::Collision');
   is ($collision2->axis, 'x', 'horizontal collision. should axis of collision be a vector?');
   is ($collision2->time, .5, 'bullet hits andy in half of a time unit');

   #test the corners
   ok (!dynamic_collision ($andy, hash2point { x=>-2, y=>0, xv=>2, yv=>2.02 }));
   ok (dynamic_collision ($andy, hash2point { x=>-2, y=>0, xv=>2, yv=>1.98 }));
   ok (!dynamic_collision ($andy, hash2point { x=>-2, y=>0, xv=>2, yv=>-2.02 }));
   ok (dynamic_collision ($andy, hash2point { x=>-2, y=>0, xv=>2, yv=>-1.98 }));
   #right
   ok (!dynamic_collision ($andy, hash2point { x=>2, y=>0, xv=>-2, yv=>2.02 }));
   ok (dynamic_collision ($andy, hash2point { x=>2, y=>0, xv=>-2, yv=>1.98 }));
   ok (!dynamic_collision ($andy, hash2point { x=>2, y=>0, xv=>-2, yv=>-2.02 }));
   ok (dynamic_collision ($andy, hash2point { x=>2, y=>0, xv=>-2, yv=>-1.98 }));
   #top
   ok (!dynamic_collision ($andy, hash2point { x=>0, y=>2, xv=>2.01, yv=>-2 }));
   ok (dynamic_collision ($andy, hash2point { x=>0, y=>2, xv=>1.99, yv=>-2 }));
   ok (!dynamic_collision ($andy, hash2point { x=>0, y=>2, xv=>-2.01, yv=>-2 }));
   ok (dynamic_collision ($andy, hash2point { x=>0, y=>2, xv=>-1.99, yv=>-2 }));
   #ass
   ok (!dynamic_collision ($andy, hash2point { x=>0, y=>-2, xv=>2.01, yv=>2 }));
   ok (dynamic_collision ($andy, hash2point { x=>0, y=>-2, xv=>1.99, yv=>2 }));
   ok (!dynamic_collision ($andy, hash2point { x=>0, y=>-2, xv=>-2.01, yv=>2 }));
   ok (dynamic_collision ($andy, hash2point { x=>0, y=>-2, xv=>-1.99, yv=>2 }));
   
   #How about where both things are moving?
   #This stuff may look failure-prone, but it actually passes when made orders of magnitude more precise
   #attempt to hit at y=20000, x=10000, t=100
   my $tiny_rect = hash2rect {x=>15000-.00005, y=>30000-.00005, h=>.0001, w=>.0001, xv=>-50, yv=>-100};
   my $accurate_bullet = hash2point { x=>-40000, y=>80100, xv=>500, yv=> -601};
   my $strange_collision = dynamic_collision ($accurate_bullet, $tiny_rect, interval=>400);
   ok($strange_collision, 'small object at long distance');
   #is ($strange_collision->axis, 'y');
   ok (99.99 < $strange_collision->time);
   ok ($strange_collision->time < 100.01);
}

{
   my $pie = hash2circle { x=>0, y=>0, radius=>1 };
   my $raisin = hash2point { x=>-2, y=>0, xv=>2 };
   my $raisin_collision = dynamic_collision($raisin,$pie);
   is ($raisin_collision->time, .5, 'raisin hits left side of pie at t=1')

}
#my $grid_environment = Collision::Util::Grid->new (file => 'level1.txt');

#let's say andy doesn't intersect any blocks in this environment.
#ok (!dynamic_collision($myrtle, $grid_environment));

#but this bullet hits a block in 1st frame or second.
#my $collision3 = dynamic_collision ($extreme_bullet, $grid_environment, interval=>1);




