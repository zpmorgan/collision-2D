package Collision::2D::Entity;
use strict;
use warnings;
require Exporter;
require DynaLoader;
our @ISA = qw(Exporter DynaLoader);


bootstrap Collision::2D::Entity;


#an actual collision at t=0; 
sub null_collision{
   my $self = shift;
   my $other = shift;
   return Collision::2D::Collision->new(
      time => 0,
      ent1 => $self,
      ent2 => $other,
   );
}

sub intersect{
   my ($self, @others) = @_;
   for (@others){
      return 1 if Collision::2D::intersection ($self, $_);
   }
   return 0;
}

sub collide{
   my ($self, $other, %params) = @_;
   return Collision::2D::dynamic_collision ($self, $other, %params);
}

1

__END__
=head1 NAME

Collision::2D::Entity - A moving entity. Don't use this directly.

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 x,y,xv,yv

Absolute position and velocity in space.
These are necessary if you want to do collisions through 
L<dynamic_collision|Collision::2D/dynamic_collision>

 dynamic_collision($circ1, $circ2);

=head2 relative_x, relative_y, relative_xv, relative_yv

Relative position and velocity in space.
these are necessary if you want to do collisions directly through entity methods,

 $circ1->collide_circle($circ2);

In this case, both the absolute and relative position and velocity of $circ2
is not used. The relative attributes of $circ1 are assumed to be relative to $circ2.


=head1 METHODS

=head2 normalize

 $self->normalize($other); # $other isa entity

This compares the absolute attributes of $self and $other.
It only sets the relative attributes of $self.
This is necessary to call collide_*($other) methods on $self.

=head2 collide

 my $collision = $self->collide ($other_entity, interval=>4);

Detect collision with another entity. $self must be normalized to $other.
Takes interval as a parameter. Returns a collision if there is a collision.
Returns undef if there is no collision.

=head2 intersect

 my $t_or_f = $self->intersect ($other_entity);

Detect intersection (overlapping) with another entity.
Takes interval as a parameter. Returns a collision if there is a collision.
Returns undef if there is no collision.

Relative vectors are not considered for intersection, so $self need not be normalized to $other.






