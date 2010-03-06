
use strict;
use warnings;

use Collision::2D ':all';

use Test::More tests => 22;

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

#now axis from point-circ and circ-circ.
{
   my $unitpie = hash2circle {x=>0,y=>0, radius=>1};
   my $pt = hash2point {x=>-1,y=>-1, xv=>1, yv=>1};
   #my $collision = dynamic_collision ($pt, $unitpie);
   $unitpie->normalize($pt);
   my $collision = $unitpie->collide_point ($unitpie, interval=>5);
   my $axis = normalize_vec ($collision->axis);
   is ($axis->[0], -sqrt(2)/2);
   is ($axis->[1], -sqrt(2)/2);
   
   my $nonpie = hash2circle {x=>-2,y=>-2, xv=>1, yv=>1};
   $nonpie->normalize($unitpie);
   my $collision2 = $nonpie->collide_circle ($unitpie, interval=>5);
   is ($collision2->time, 2-sqrt(2));
   my $axis2 = normalize_vec ($collision2->axis);
   is ($axis2->[0], sqrt(2)/2);
   is ($axis2->[1], sqrt(2)/2);
   
}

#now do bounce vectors
{
   my $tallrect = hash2rect {x=>0,y=>-100, h=>200};
   #point from left
   my $px_pt = hash2point {x=>-1.222,y=>1.666,xv=>2, yv=>1};
   my $px_collision = dynamic_collision ($px_pt, $tallrect);
   my $bounce_vec = $px_collision->bounce_vector;
   is ($bounce_vec->[0], -2);
   is ($bounce_vec->[1], 1);
   
   
   my $widerect = hash2rect {x=>-100, w=>200, y=>0, h=>1};
   #point from above, moving right. hit at y=1.
   my $ny_pt = hash2point {x=>5,y=>8, xv=>.21212, yv=>-2};
   my $ny_collision = dynamic_collision ($ny_pt, $widerect, interval=>20);
   #is ($py_collision->axis, 'y');
   #is ($ny_collision->maxis->[0], .21212);
   #is ($ny_collision->maxis->[1], 2);
   
   
   
   
   #now do 2 moving circles  both moving horizontal, but bounce
   # each other into y dimension
   my $pxcirc = hash2circle {x=>-2, y=>-sqrt(2), xv=> 100, radius=>2 , y=>.888 };
   my $nxcirc = hash2circle {x=> 2, y=> sqrt(2), xv=>-100, radius=>2 , y=>.888 };
   
   $pxcirc->normalize($nxcirc);
   my $circ_collision = $pxcirc->collide_circle ($nxcirc, interval=>1);
   my $cbvec = $circ_collision->bounce_vector;
   my $rcbvec = $circ_collision->bounce_vector (relative=>1);
   my $icbvec = $circ_collision->bounce_vector (elasticity=>0, relative=>1);
   
   is ($cbvec->[0], 0, 'elastic circle bounce'); #-100
   is ($cbvec->[1], -100 - .888, 'elastic circle bounce'); #0
   is ($rcbvec->[0], 0, 'relative circle bounce'); #-200
   is ($rcbvec->[1], -100, 'relative circle bounce'); #0
   is ($cbvec->[0], 100*sqrt(2)/2, 'inelastic circle bounce'); #-100
   is ($cbvec->[1], -100*sqrt(2)/2, 'inelastic circle bounce'); #0
   
}