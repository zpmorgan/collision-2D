package Collision::2D::Entity::Rect;
use Mouse;
extends 'Collision::2D::Entity';

sub _p{4} #low priority
use overload '""'  => sub{'rect'};

has 'w' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
   default=>1,
);
has 'h' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
   default=>1,
);

sub intersect_rect{
   my ($self, $other) = @_;
   return (
               ($self->x < $other->x + $other->w) 
            && ($self->y < $other->y + $other->h) 
            && ($self->x + $self->w > $other->x) 
            && ($self->y + $self->h > $other->y));
}

sub collide_rect{
   my ($self, $other, %params) = @_;
   my $x1 = $self->relative_x;
   my $x2 = $x1 + ($self->relative_xv * $params{interval});
   my $y1 = $self->relative_y;
   my $y2 = $y1 + ($self->relative_yv * $params{interval});
   my $sw = $self->w;
   my $sh = $self->h;
   my $ow = $other->w;
   my $oh = $other->h;
   
   #start intersected?
   return $self->null_collision($other) if (
      $y1+$sh > 0 and 
      $x1+$sw > 0 and
      $x1 < $ow and
      $y1 < $oh
   );
   #miss entirely?
   return if ( $x1+$sw < 0 and $x2+$sw < 0
            or $x1 > $ow and $x2 > $ow
            or $y1+$sh < 0 and $y2+$sh < 0
            or $y1 > $oh and $y2 > $oh
   );
   my $best_time = $params{interval}+1;
   my $best_axis;
   
   if ($x1+$sw < 0){ #hit on left of $other
      $best_time = -($x1+$sw)/$self->relative_xv;
      $best_axis = 'x';
   }
   if ($y1+$sh < 0){ #hit on bottom of $other
      my $time = -($y1+$sh)/$self->relative_yv;
      if ($time<$best_time){
         $best_time = $time;
         $best_axis = 'y';
      }
   }
   if ($x1 > $ow){ #hit on right of $other
      my $time = -($x1 - $ow)/$self->relative_xv;
      if ($time<$best_time){
         $best_time = $time;
         $best_axis = 'x';
      }
   }
   if ($y1 > $oh){ #hit on right of $top
      my $time = -($y1 - $oh)/$self->relative_yv;
      if ($time<$best_time){
         $best_time = $time;
         $best_axis = 'y';
      }
   }
   
   if ($best_time <= $params{interval}){
      return Collision::2D::Collision->new(
         axis => $best_axis,
         time => $best_time,
         ent1 => $self,
         ent2 => $other,
      );
   }
   return;
}

sub contains_point{
   my ($self, $point) = @_;
   return ($point->x > $self->x
      and  $point->y > $self->y
      and  $point->x < $self->x + $self->w
      and  $point->y < $self->y + $self->h);
}

no Mouse;
__PACKAGE__->meta->make_immutable;

3
