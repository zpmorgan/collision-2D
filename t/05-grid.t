
use strict;
use warnings;

use Collision::2D ':all';

use Test::More  tests => 17;

#grids are an optimization, but here I suppose we'll just test function rather than performance

#motionless circle with points on grid
{
   my $pie = hash2circle {x=>1.8888, y=>-1.1234, radius=>2}; #motionless
   my $grid = hash2grid {x=>-15, y=>-15, w=>30, h=>30,  cell_size => .888 };
   my @points_in = (
      hash2point ({x=>1.8887 + sqrt(2), y=>-1.1234 + sqrt(2)}),
      hash2point ({x=>1.8887 + sqrt(2), y=>-1.1234 - sqrt(2)}),
      hash2point ({x=>1.8889 - sqrt(2), y=>-1.1234 - sqrt(2)}),
      hash2point ({x=>1.8889 - sqrt(2), y=>-1.1234 + sqrt(2)}),
   );
   my @points_out = (
      hash2point ({x=>1.8887 - sqrt(2), y=>-1.1234 - sqrt(2)}),
      hash2point ({x=>1.8887 - sqrt(2), y=>-1.1234 + sqrt(2)}),
      hash2point ({x=>1.8889 + sqrt(2), y=>-1.1234 + sqrt(2)}),
      hash2point ({x=>1.8889 + sqrt(2), y=>-1.1234 - sqrt(2)}),
   );
   #$grid->add_point ($_) for (@points_in, @points_out);
   $grid->add_circle($pie);
   
   ok (intersection ($grid, $points_in[0]), 'NE collision');
   ok (intersection ($grid, $points_in[1]), 'SE collision');
   ok (intersection ($grid, $points_in[2]), 'SW collision');
   ok (intersection ($grid, $points_in[3]), 'NW collision');
   ok (!intersection ($grid, $points_out[0]), 'NE non-collision');
   ok (!intersection ($grid, $points_out[1]), 'SE non-collision');
   ok (!intersection ($grid, $points_out[2]), 'SW non-collision');
   ok (!intersection ($grid, $points_out[3]), 'NW non-collision');
}

# just a circle on grid
{
   
   my $pie = hash2circle {x=>.5, y=>.5, radius=>1.01}; #motionless
   my $grid = hash2grid {x=>-1, y=>-1, w=>3, h=>3,  cell_size => 1 };
   $grid->add_circle ($pie);
   
   ok ($grid->table->[1][1], 'circle is primarily here');
   ok ($grid->table->[1][2], 'cell clips right of circle');
   ok ($grid->table->[1][0], 'cell clips left of circle');
   ok ($grid->table->[2][1], 'cell clips top of circle');
   ok ($grid->table->[0][1], 'cell clips bottom of circle');
   ok (!$grid->table->[2][2], 'circle is not in top-right');
   ok (!$grid->table->[2][0], 'circle is not in top-left');
   ok (!$grid->table->[0][0], 'circle is not in bottom-left');
   ok (!$grid->table->[0][0], 'circle is not in bottom-right');
   
   
}
