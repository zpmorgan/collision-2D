package Collision::2D::Collision;
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
   isa => 'Collision::2D::Entity',
   is => 'ro',
);
has 'ent2' => (
   isa => 'Collision::2D::Entity',
   is => 'ro',
);

sub maxis{
   my $self = shift;
   my $axis = $self->axis;
   return unless $axis;
   return $axis if ref $axis eq 'ARRAY';
   if ($axis eq 'x'){
      if ($self->ent1->relative_xv > 0){
         return [1,0];
      }
      return [-1,0];
   }
   #$axis eq 'y'
   if ($self->ent1->relative_yv > 0){
      return [0,1];
   }
   return [0,-1];
}

sub does_mario_defeat_goomba{}

sub bounce_vector{
   
}
sub remaining_interval{
   
}

1

__END__
=head1 NAME

Collision::2D::Collision - An object representing a collision betwixt 2 entities

=head1 DESCRIPTION

=head1 ATTRIBUTES

=over

=item time

The time of collision. For example, cinsider a point-circle collision,
where the point is moving towards the circle. 
$collision->time is the B<exact> moment of collision between the two.

=item axis

The axis of collision. Basically a vector from one entity to the other.
It depends entirely on how they collide.

If the collision involves a vertical or horizontal line, the axis will be
'x' or 'y'. If it's between a point or corner and a circle, it will be
an arrayref, of the form [$x,$y].

This vector will not be normal (normal means of length 1).
L<Collision::2D::normalize_vec($v)|Collision::2D/normalize_vec>
is provided for that purpose.

=item ent1, ent2

 $collision->ent1

This is to provide some context for L</axis>. This is useful because
dynamic_collision doesn't preserve the order of your entities.

=back

