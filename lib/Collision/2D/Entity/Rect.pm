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
   return ($_[0]->x <= $_[1]->x) #wat?
            && ($_[0]->y <= $_[1]->y) #wat?
            && ($_[0]->x + $_[0]->w >= $_[1]->x + $_[1]->w) 
            && ($_[0]->y + $_[0]->h >= $_[1]->y + $_[1]->h) 
            && ($_[0]->x + $_[0]->w > $_[1]->x) 
            && ($_[0]->y + $_[0]->h > $_[1]->y);
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
   
   my @collisions;
   #with 3 closest points on $this, see if they enter $other
   #and vice versa. pick closest of all detected collisions.
   my @own_pts = (
      {x=>$x1,    y=>$y1},
      {x=>$x1+$sw, y=>$y1},
      {x=>$x1+$sw, y=>$y1+$sh},
      {x=>$x1,    y=>$y1+$sh},
   );
   for (@own_pts){ #calc initial distance from center of circle
      $_->{dist} = sqrt($_->{x}**2 + $_->{y}**2);
   }
   @own_pts = sort {$a->{dist} <=> $b->{dist}} @own_pts;
   for (@own_pts[0,1,2]){ #do this for 3 initially closest rect corners
      my $r_pt = Collision::2D::Entity::Point->new(
         relative_x =>  $_->{x},
         relative_y =>  $_->{y},
         relative_xv => $self->relative_xv,
         relative_yv => $self->relative_yv,
      );
      my $collision = $r_pt->collide_rect ($other, interval=>$params{interval});
      next unless $collision;
      push @collisions, Collision::2D::Collision->new(
         axis => $collision->axis,
         time => $collision->time,
         ent1 => $self,
         ent2 => $other,
      );
   }
   
   #now do the exact same for the other
   my @other_pts = (
      {x=>-$x1,    y=>-$y1},
      {x=>-$x1-$ow, y=>-$y1},
      {x=>-$x1-$ow, y=>-$y1-$oh},
      {x=>-$x1,    y=>-$y1-$oh},
   );
   for (@other_pts){ #calc initial distance from center of circle
      $_->{dist} = sqrt($_->{x}**2 + $_->{y}**2);
   }
   @other_pts = sort {$a->{dist} <=> $b->{dist}} @other_pts;
   for (@other_pts[0,1,2]){ #do this for 3 initially closest rect corners
      my $r_pt = Collision::2D::Entity::Point->new(
         relative_x =>  $_->{x},
         relative_y =>  $_->{y},
         relative_xv => -$self->relative_xv,
         relative_yv => -$self->relative_yv,
      );
      my $collision = $r_pt->collide_rect ($self, interval=>$params{interval});
      next unless $collision;
      push @collisions, Collision::2D::Collision->new(
         axis => $collision->axis,
         time => $collision->time,
         ent1 => $other,
         ent2 => $self,
      );
   }
   return unless @collisions;
   @collisions = sort {$a->time <=> $b->time} @collisions;
   #warn join ',', @collisions;
   return $collisions[0]
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
