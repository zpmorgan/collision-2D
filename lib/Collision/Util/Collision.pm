package Collision::Util::Collision;
use Mouse;

#this might be of use for calculating bounce vectors based on axes of collision. 
# http://www.members.shaw.ca/mathematica/ahabTutorials/2dCollision.html

has 'axis' => (
   is => 'ro',
   #isa => 
);

has 'time' => (
   is => 'ro',
   isa => 'Num',
   default=> 0,
);
has 'ent1' => (
   isa => 'Collision::Util::Entity',
   is => 'ro',
);
has 'ent2' => (
   isa => 'Collision::Util::Entity',
   is => 'ro',
);

sub does_mario_defeat_goomba{}

sub bounce_vector{
   
}
sub remaining_interval{
   
}

1
