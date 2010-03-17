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
   my $xv = $self->relative_xv;
   my $yv = $self->relative_yv;
   my $x1 = $self->relative_x;
   my $y1 = $self->relative_y;
   my $x2 = $x1 + ($xv * $params{interval});
   my $y2 = $y1 + ($yv * $params{interval});
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
      my $time = -($x1+$sw)/$xv;
      my $yatt = $y1+$yv*$time;
      if ($yatt + $sh > 0 and $yatt < $oh){
         $best_time = $time;
         $best_axis = 'x';
      }
   }
   if ($y1+$sh < 0){ #hit on bottom of $other
      my $time = -($y1+$sh)/$yv;
      if ($time<$best_time){
         my $xatt = $x1+$xv*$time;
         if ($xatt + $sw > 0 and $xatt < $ow){
            $best_time = $time;
            $best_axis = 'y';
         }
      }
   }
   if ($x1 > $ow){ #hit on right of $other
      my $time = -($x1 - $ow)/$xv;
      if ($time<$best_time){
         my $yatt = $y1+$yv*$time;
         if ($yatt + $sh > 0 and $yatt < $oh){
            $best_time = $time;
            $best_axis = 'x';
         }
      }
   }
   if ($y1 > $oh){ #hit on right of $top
      my $time = -($y1 - $oh)/$yv;
      if ($time<$best_time){
         my $xatt = $x1+$xv*$time;
         if ($xatt + $sw > 0 and $xatt < $ow){
            $best_time = $time;
            $best_axis = 'y';
         }
      }
   }
   
   if ($best_time <= $params{interval}){
   warn $best_time;
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
