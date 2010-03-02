package Collision::Util::Entity::Rect;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'rect'};

has 'w' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
);
has 'h' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
);

sub collide_rect{
   
}

sub contains_point{
   my ($self, $point) = @_;
   return ($point->x > $self->x
      and  $point->y > $self->y
      and  $point->x < $self->x + $self->w
      and  $point->y < $self->y + $self->h);
}


3
