
use strict;
use warnings;

use Collision::2D ':all';

use Test::More tests => 8;

#grids are an optimization, but here I suppose we'll just test function rather than performance

#motionless circle with grid
{
   my $pie = hash2circle {x=>1.8888, y=>-1.1234, radius=>2}; #motionless
   my $grid = hash2grid {x=>-15, y=>-15, w=>30, h=>30});
   my @points_in = (
      hash2point {x=>1.8887 + sqrt(2), y=>-1.1233 + sqrt(2)},
      hash2point {x=>1.8887 + sqrt(2), y=>-1.1235 - sqrt(2)},
      hash2point {x=>1.8889 - sqrt(2), y=>-1.1235 - sqrt(2)},
      hash2point {x=>1.8889 - sqrt(2), y=>-1.1233 + sqrt(2)},
   );
   my @points_out = (
      hash2point {x=>1.8887 - sqrt(2), y=>-1.1233 - sqrt(2)},
      hash2point {x=>1.8887 - sqrt(2), y=>-1.1235 + sqrt(2)},
      hash2point {x=>1.8889 + sqrt(2), y=>-1.1235 + sqrt(2)},
      hash2point {x=>1.8889 + sqrt(2), y=>-1.1233 - sqrt(2)},
   );
   $grid->add (@points_in, @points_out);
   
   my @in_collisions = map {dynamic_collision ($grid, $_}) @points_in;
   my @out_collisions = map {dynamic_collision ($grid, $_}) @points_out;
   
   ok ($in_collisions[0], 'NE collision');
   ok ($in_collisions[1], 'SE collision');
   ok ($in_collisions[2], 'SW collision');
   ok ($in_collisions[3], 'NW collision');
   ok (!$out_collisions[0], 'NE non-collision');
   ok (!$out_collisions[1], 'SE non-collision');
   ok (!$out_collisions[2], 'SW non-collision');
   ok (!$out_collisions[3], 'NW non-collision');
}
