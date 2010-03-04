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

sub intersects_rect{
   return ($_[0]->x <= $_[1]->x) 
            && ($_[0]->y <= $_[1]->y) 
            && ($_[0]->x + $_[0]->w >= $_[1]->x + $_[1]->w) 
            && ($_[0]->y + $_[0]->h >= $_[1]->y + $_[1]->h) 
            && ($_[0]->x + $_[0]->w > $_[1]->x) 
            && ($_[0]->y + $_[0]->h > $_[1]->y);
}

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
