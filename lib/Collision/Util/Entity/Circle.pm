package Collision::Util::Entity::Circle;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'circle'};

has 'radius' => (
   is => 'ro',
   isa => 'Num',
);

# http://www.members.shaw.ca/mathematica/ahabTutorials/2dCollision.html
sub collide_circle{
   my ($self, $other, %params) = @_;
   
}
sub collide_rect{
   my ($self, $rect, %params) = @_;
   
}

sub collide_point{
   my ($self, $point, %params) = @_;
   
}


3