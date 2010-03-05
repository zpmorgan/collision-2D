
use strict;
use warnings;

use Collision::2D ':all';

use Test::More tests => 12;

#first, bounce point off rect
{
   my $tallrect = hash2rect {x=>0,y=>-100, h=>200};
   #point from left
   my $px_pt = hash2point {x=>-1,y=>0,xv=>2};
   my $px_collision = dynamic_collision ($px_pt, $tallrect);
   is ($px_collision->axis, 'x');
   is ($px_collision->maxis->[0], 1);
   is ($px_collision->maxis->[1], 0);
   
   #point from right
   my $nx_pt = hash2point {x=>2,y=>0,xv=>-2};
   my $nx_collision = dynamic_collision ($nx_pt, $tallrect);
   is ($nx_collision->axis, 'x');
   is ($nx_collision->maxis->[0], -1);
   is ($nx_collision->maxis->[1], 0);
   
   
   my $widerect = hash2rect {y=>0,x=>-100, w=>200};
   #point from below
   my $py_pt = hash2point {x=>0,y=>-1,yv=>2};
   my $py_collision = dynamic_collision ($py_pt, $widerect);
   is ($py_collision->axis, 'y');
   is ($py_collision->maxis->[0], 0);
   is ($py_collision->maxis->[1], 1);
   
   #from above
   my $ny_pt = hash2point {x=>0,y=>2,yv=>-2};
   my $ny_collision = dynamic_collision ($ny_pt, $widerect);
   is ($ny_collision->axis, 'y');
   is ($ny_collision->maxis->[0], 0);
   is ($ny_collision->maxis->[1], -1);
}
