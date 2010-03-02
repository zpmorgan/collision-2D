package Collision::Util::Entity;
use Mouse;

use overload '""'  => sub{'entity'};

has 'x' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
);
has 'y' => (
   isa => 'Num',
   is => 'ro',
   required => 1,
);

has 'xv' => (
   isa => 'Num',
   is => 'ro',
   default => 0,
);
has 'yv' => (
   isa => 'Num',
   is => 'ro',
   default => 0,
);

has 'relative_x' => (
   isa => 'Num',
   is => 'rw',
);
has 'relative_y' => (
   isa => 'Num',
   is => 'rw',
);

has 'relative_xv' => (
   isa => 'Num',
   is => 'rw',
);
has 'relative_yv' => (
   isa => 'Num',
   is => 'rw',
);

sub normalize{
   my ($self, $other) = @_;
   $self->relative_x ($self->x - $other->x);
   $self->relative_y ($self->y - $other->y);
   $self->relative_xv ($self->xv - $other->xv);
   $self->relative_yv ($self->yv - $other->yv);
}

#an actual collision at t=0; 
sub null_collision{
   my $self = shift;
   my $other = shift;
   return Collision::Util::Collision->new(
      time => 0,
      ent1 => $self,
      ent2 => $other,
   );
}


2
