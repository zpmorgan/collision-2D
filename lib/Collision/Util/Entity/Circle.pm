package Collision::Util::Entity::Circle;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'circle'};

#in a circle, x and y denote center. 

has 'radius' => (
   is => 'ro',
   isa => 'Num',
   default => 1,
);



sub intersects_circle{
   my ($self, $other) = @_;
   return 1 if  ($self->radius + $other->radius)
      > sqrt(($self->x - $other->x)**2 + ($self->y - $other->y)**2);
   return 0;
}
sub intersects_point{
   my ($self, $point) = @_;
   return 1 if sqrt(($self->x - $point->x)**2 + ($self->y - $point->y)**2) < $self->radius;
   return 0;
}


sub collide_rect{
   my ($self, $rect, %params) = @_;
   my @collisions;
   
   #my doing this we can consider $self to be stationary and $rect to be moving.
   #this line segment is path of rect during this interval
   my $r = $self->radius;
   my $w = $rect->w;
   my $h = $rect->h;
   my $x1 = -$self->relative_x; #of rect!
   my $x2 = $x1 - ($self->relative_xv * $params{interval});
   my $y1 = -$self->relative_y;
   my $y2 = $y1 - ($self->relative_yv * $params{interval});
   
   #now see if point starts and ends on one of 4 sides of this rect.
   #probably worth it because most things don't collide with each other every frame
   if ($x1 > $r and $x2 > $r ){
      return
   }
   if ($x1+$w < -$r and $x2+$w < -$r){
      return
   }
   if ($y1 > $r and $y2 > $r ){
      return
   }
   if ($y1+$h < -$r and $y2+$h < -$r){
      return
   }
   
   #which of rect's 4 points should I consider?
   my @start_pts = ([$x1, $y1], [$x1+$w, $y1], [$x1+$w, $y1+$h], [$x1, $y1+$h]);
   my @end_pts = ([$x2, $y2], [$x2+$w, $y2], [$x2+$w, $y2+$h], [$x2, $y2+$h]);
   my @pts = (
      {x1 => $x1,    y1 => $y1},
      {x1 => $x1+$w, y1 => $y1},
      {x1 => $x1+$w, y1 => $y1+$h},
      {x1 => $x1,    y1 => $y1+$h},
   );
   for (@pts){ #calc initial distance from center of circle
      $_->{dist} = sqrt($_->{x1}**2 + $_->{y1}**2);
   }
   my $origin_point = Collision::Util::Entity::Point->new(
     # x => 0,y => 0, #actually not used, since circle is normalized with respect to the point
   );
   @pts = sort {$a->{dist} <=> $b->{dist}} @pts;
   for (@pts[0,1,2]){ #do this for 3 initially closest points
      my $new_relative_circle = Collision::Util::Entity::Circle->new(
        # x => 0,y => 0, # used
         relative_x => -$_->{x1},
         relative_y => -$_->{x1},
         relative_xv => $self->relative_xv,
         relative_yv => $self->relative_yv,
      );
      my $collision = $new_relative_circle->collide_point ($origin_point, interval=>$params{interval});
      next unless $collision;
      #$_->{collision} = 
      push @collisions, Collision::Util::Collision->new(
         axis => $collision->axis,
         time => $collision->time,
         ent1 => $self,
         ent2 => $rect,
      );
   }
   
   # that looked at the rect corners. that was half of it. 
   # now look for collisions between a side of the circle
   #  and a side of the rect
   my @circ_points; #these are relative coordinates to rect
   if ($x1+$w+$r < 0  and  $x2+$w+$r > 0){
      #add circle's left point
      push @circ_points, [-$x1-$r,-$y1];
   }
   if ($x1+$r > 0  and  $x2+$r < 0){
      #add circle's right point
      push @circ_points, [-$x1+$r,-$y1];
   }
   if ($y1+$h+$r < 0  and  $y2+$h+$r > 0){
      #add circle's bottom point
      push @circ_points, [-$x1,-$y1-$r];
   }
   if ($y1+$r > 0  and  $y2+$r < 0){
      #add circle's top point
      push @circ_points, [-$x1,-$y1+$r];
   }   #   warn @{$circ_points[0]};
   for (@circ_points){
      my $rpt = Collision::Util::Entity::Point->new(
         relative_x => $_->[0],
         relative_y => $_->[1],
         relative_xv => $self->relative_xv,
         relative_yv => $self->relative_yv,
      );
      my $collision = $rpt->collide_rect($rect, interval=>$params{interval});
      next unless $collision;
      push @collisions, new Collision::Util::Collision(
         time => $collision->time,
         axis => $collision->axis,
         ent1 => $self,
         ent2 => $rect,
      );
   }
   return unless @collisions;
   @collisions = sort {$a->time <=> $b->time} @collisions;
   return $collisions[0]
}




#ok, so normal circle is sqrt(x**2+y**2)=r
#and line is y=mx+b (invert line if line is vertical)
#to find their intersection on the x axis,
# sqrt(x**2 + (mx+b)**2) = r
#  x**2 + (mx)**2 + mxb + b**2 = r**2
#   (m**2+1)x**2 + (2mb)x + (b**2-r**2) = 0.
#solve using quadratic equation
# A=m**2+1
# B=2mb
# C=b**2-r**2
# roots (where circle intersects on the x axis) are at
# ( -B ± sqrt(B**2 - 4AC) ) / 2A
#Then, see which intercept, if any, is the closest after starting point
sub collide_point{
   my ($self, $point, %params) = @_;
   #my $r = $self->radius;
   #if ($self->intersects_point($point)){
   #   return $self->null_collision($point);
   #}
   #x1,etc. is the path of the point, relative to $self.
   #it's probably easier to consider the point as stationary.
   my $x1 = -$self->relative_x;
   my $y1 = -$self->relative_y;
   my $x2 = $x1 - $self->relative_xv * $params{interval};
   my $y2 = $y1 - $self->relative_yv * $params{interval};
   
   if (sqrt($x1**2 + $y1**2) < $self->radius) {
      return $self->null_collision($point);
   }
   
   if ($x2-$x1 == 0  or  abs(($y2-$y1)/($x2-$x1)) > 100) { #a bit too vertical for my liking. so invert.
      if ($y2-$y1 == 0){ #relatively motionless.
         return
      }
      ($x1, $y1) = ($y1,$x1);
      ($x2, $y2) = ($y2,$x2);
   }
   
   #now do quadratic
   my $slope = ($y2-$y1)/($x2-$x1);
   my $y_intercept = $y1 - $slope*$x1;
   my $A = $slope**2 + 1; #really?
   my $B = 2 * $slope*$y_intercept;
   my $C = $y_intercept**2 - $self->radius**2;
   my @xi; #x component of intersections.
   if ($A==0){ #true quadratic equation would divide by 0.
      #Bx+C=0 so x=C/B
      return if $B==0; #not sure if this seems right.
      push @xi, ($C/$B)
   }
   else{
      my $blah = $B**2 - 4*$A*$C;
      return unless $blah>0;
      $blah = sqrt($blah);
      push @xi, (-$B + $blah ) / (2*$A);
      push @xi, (-$B - $blah ) / (2*$A);
   }
   #keep intersections within segment
   @xi = grep {($_>=$x1 and $_<=$x2) or ($_<=$x1 and $_>=$x2)} @xi;
   #sort based on closeness to starting point.
   @xi = sort {abs($a-$x1) <=> abs($b-$x1)} @xi;
   return unless defined $xi[0];
   
   #get away from invertedness
   my $time = $params{interval} * ($xi[0]-$x1) / ($x2-$x1);
   my $x_at_t = $self->relative_x + $self->relative_xv*$time;
   my $y_at_t = $self->relative_y + $self->relative_yv*$time;
   my $axis = [-$x_at_t, -$y_at_t]; #vector from self to point
   
   my $collision = Collision::Util::Collision->new(
      time => $time,
      axis => $axis,
      ent1 => $self,
      ent2 => $point,
   );
   return $collision;
}

#Say, can't we just use the point algorithm by transferring the radius of one circle to the other?
sub collide_circle{
   my ($self, $other, %params) = @_;
   my $double_trouble = Collision::Util::Entity::Circle->new(
      relative_x => $self->relative_x,
      relative_y => $self->relative_y,
      relative_xv => $self->relative_xv,
      relative_yv => $self->relative_yv,
      radius => $self->radius + $other->radius,
      y=>0,x=>0, #these will not be used, as we're doing all relative calculations
   );
   
   my $pt = Collision::Util::Entity::Point->new(
      y=>44,x=>44, #these willn't be used, as we're doing all relative calculations
   );
   my $collision = $double_trouble->collide_point($pt, %params);
   return unless $collision;
   return Collision::Util::Collision->new(
      ent1 => $self,
      ent2 => $other,
      time => $collision->time,
      axis => $collision->axis,
   );
}




3
