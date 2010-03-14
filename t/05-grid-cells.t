
use strict;
use warnings;
no warnings 'qw';

use Collision::2D ':all';

use Test::More  tests => 21;

#motionless circle with rects on grids
# the rects represent cells

#cell (0,0) to (1,1) is center cell
#put a rect in this grid at specified coordinates
sub grid_3x3{
   my ($x,$y) = @_;
   my $grid = hash2grid {x=>-1,y=>-1, w=>3,h=>3, cell_size => 1};
   if (defined $x){
      #be a good citizen and don't touch your neighbors.
      my $rect = hash2rect {x=>$x+.0001, y=>$y+.0001, w=>.9998, h=>.9998};
      $grid->add_rect ($rect);
   }
   return $grid;
}

#not an acronym. the animal. provides test names..
my @COW = qw|(-1,-1) (0,-1) (1,-1)  (-1,0) (0,0) (1,0)  (-1,1) (0,1) (1,1) |;

my @grids; #[4] at center, [3..5] is center row, [6..8] is top row..
for my $y(-1..1){
   for my $x(-1..1){
      push @grids, grid_3x3 ($x, $y);
   }
}

is (ref $grids[4]->table->[1][1][0], 'Collision::2D::Entity::Rect', 'rect in center cell of its rep. grid');


#start with a circle vs. 9-celled grids
{
   my $smallest_circle = hash2circle {x=>.5, y=>.5, radius=>.49}; #1 cell
   my $corner_circle = hash2circle {x=>-.5, y=>-.5, radius=>.49}; #1 cell
   my $small_circle = hash2circle {x=>.5, y=>.5, radius=>.51}; #5 cells
   my $med_circle = hash2circle {x=>.5, y=>.5, radius=> sqrt(2)/2 - .01}; #5 cells
   my $large_circle = hash2circle {x=>.5, y=>.5, radius=> sqrt(2)/2 + .01}; #9 cells
   
   
   is ( grid_3x3()->cells_intersect_circle($smallest_circle), 1,
         'smallest_circle intersects 1 cell');
   ok ($smallest_circle->intersect($grids[4]), 'smallest vs. center square');
   ok (!$smallest_circle->intersect($grids[$_]), 'smallest_circle vs. grid '.$COW[$_])
         for (0..3,5..8);
   
   is ( grid_3x3()->cells_intersect_circle($corner_circle), 1,
         'corner intersects 1 cell');
   ok ($corner_circle->intersect($grids[0]), 'corner_circle vs. corner square');
   ok (!$corner_circle->intersect($grids[$_]), 'corner_circle vs. grid '.$COW[$_])
         for (1..8);
   
}





