package Collision::Util::Entity::Circle;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'circle'};

#in a circle, x and y denote center. 

has 'radius' => (
   is => 'ro',
   isa => 'Num',
);

sub invert_collide_circle_and_collision{
   my ($self, $other, %params) = @_;
   my $new_self = Collision::Util::Entity::Circle->new(
      relative_x => $self->relative_y,
      relative_y => $self->relative_x,
      relative_vx => $self->relative_vy,
      relative_vy => $self->relative_vx,
      radius => $self->radius,
   );
   my $collision = $new_self->collide_circle($other, %params);
   return Collision::Util::Collision->new(
      axis => invert_axis($collision->axis),
      time=>$collision->time,
      ent1=>$self,
      ent2=>$other,
   );
}


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
   if ($self->intersects_point($point)){
      return $self->null_collision($point);
   }
   #x1,etc. is the path of the point, relative to $self.
   #it's probably easier to consider the point as stationary.
   my $x1 = -$self->relative_x;
   my $y1 = -$self->relative_y;
   my $x2 = $x1 - $self->relative_xv * $params{interval};
   my $y2 = $y1 - $self->relative_yv * $params{interval};
   
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
   my $pt = Collision::Util::Entity::Point->new(
      relative_x => $self->relative_x,
      relative_y => $self->relative_y,
      relative_vx => $self->relative_vx,
      relative_vy => $self->relative_vy,
   );
   my $double_trouble = Collision::Util::Entity::Circle->new(
      radius => $self->radius + $other->radius,
   );
   my $collision = $double_trouble->collide_point($pt, %params);
}




3
