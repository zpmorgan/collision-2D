
use strict;
use warnings;

#use Collision::Util ':all';
use Collision::Util::Dynamic ':all';

use Test::More tests => 20;

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
}


#my $grid_environment = Collision::Util::Grid->new (file => 'level1.txt');

#let's say andy doesn't intersect any blocks in this environment.
#ok (!dynamic_collision($myrtle, $grid_environment));

#but this bullet hits a block in 1st frame or second.
#my $collision3 = dynamic_collision ($extreme_bullet, $grid_environment, interval=>1);




