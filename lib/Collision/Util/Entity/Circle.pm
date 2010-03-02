package Collision::Util::Entity::Circle;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'circle'};

#in a circle, x and y denote center. 

has 'radius' => (
   is => 'ro',
   isa => 'Num',
);

# http://www.members.shaw.ca/mathematica/ahabTutorials/2dCollision.html
sub collide_circleFOO{
   my ($self, $other, %params) = @_;
   #if we start overlaping, return the null collision, so to speak.
   if ($self->intersects_circle($other)){
      return $self->null_collision($other)
   }
   else{
      #start outside box, so return if no relative movement 
      return unless $params{interval} and ($self->relative_x or $self->relative_y);
   }
   #now do something about vertical lines. if vertical, or almost vertical, invert everything.
   if ($self->relative_xv == 0 or ($self->relative_yv/$self->relative_xv < .001) ){
      return $self->invert_collide_circle_and_collision($other);
   }}
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

#http://mathworld.wolfram.com/Circle-LineIntersection.html
sub collide_point{
   my ($self, $point, %params) = @_;
   my $r = $self->radius;
   my $x1 = $self->relative_x;
   my $y1 = $self->relative_y;
   my $x2 = $self->relative_xv * $params{interval};
   my $y2 = $self->relative_yv * $params{interval};
   my $D = $x1*$y2 - $x2*$y1; #determinant
   my $dx = $x2-$x1;
   my $dy = $y2-$y1;
   my $dr = sqrt ($dx**2 + $dy**2);
   #negative discriminant means no intersection
   return unless ($r**2 * $dr**2) - $D > 0;
   
   my $sgn = ($dy<0) ? -1 : 1;
   my $x_intersect1 = ($D*$dy - $sgn*$dx*sqrt($r**2 * $dr**2 - $D**2))
                      / $dr**2;
   my $x_intersect2 = ($D*$dy + $sgn*$dx*sqrt($r**2 * $dr**2 - $D**2))
                      / $dr**2;
   my $y_intersect1 = (-$D*$dx - abs($dy)*sqrt($r**2 * $dr**2 - $D**2))
                      / $dr**2;
   my $y_intersect2 = (-$D*$dx + abs($dy)*sqrt($r**2 * $dr**2 - $D**2))
                      / $dr**2;
   my $t1 = $self->relative_xv * ($x_intersect1-$x1);
   my $t2 = $self->relative_xv * ($x_intersect2-$x1);
   return Collision::Util::Collision->new(
      axis => ($t1<$t2) ? [$x_intersect1, $y_intersect1] : [$x_intersect2, $y_intersect2],
      time => ($t1<$t2)?$t1:$t2,
      ent1=>$self,
      ent2=>$point,
   );
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
