package Collision::2D::Entity::Grid; 
use Mouse;
extends 'Collision::2D::Entity';
use List::AllUtils qw/max min/;
use POSIX qw(ceil floor);

sub _p{1} #highest priority -- include all relevant methods in this module
use overload '""'  => sub{'grid'};


# table where we store every grid child;
# in each cell, a list of entities which intersect it
# table is a list of rows, so it's table->[y][x] = [ent,...]
has table => (
   isa => 'ArrayRef[ArrayRef[ArrayRef[Collision::2D::Entity]]]',
   is  => 'ro',
   lazy => 1,
   default => sub {
      [];
   },
);

has $_      => (
   isa => 'Num',
   is  => 'ro',
   default => 0,
) for qw/w h/;

#there's a reason you can't find, say, cell row count with @{$grid->table}
#that reason is autovivication
has cells_x => (
   isa => 'Int',
   is  => 'ro',
   lazy  => 1,
   default => sub{
      return ceil( $_[0]->w / $_[0]->cell_size)
   },
);
has cells_y => (
   isa => 'Int',
   is  => 'ro',
   lazy  => 1,
   default => sub{
      return ceil( $_[0]->h / $_[0]->cell_size)
   },
);

# granularity; cells will be squares of this size
has cell_size => ( 
   isa => 'Num',
   is  => 'ro',
);

sub add{
   my ($self, @others) = @_;
   for (@others){
      if (ref $_ eq 'ARRAY'){
         $self->add(@$_);
      }
      my $method = "add_$_";
      $self->$method($_);
   }
   
}


#nonmoving circle, not necessarily normalized
#returns list of [cell_x,cell_y],...
sub cells_intersect_circle{
   my ($self, $circle) = @_;
   my @cells; # [int,int], ...
   
   #must find a faster way to find points inside
   my $r = $circle->radius;
   my $rx = $circle->x - $self->x; #relative
   my $ry = $circle->y - $self->y;
   my $s = $self->cell_size;
   
   for my $y ( max(0, ($ry-$r)/$s) .. floor min ($self->cells_y-1, ($ry+$r)/$s) ) {
      for my $x ( max(0, ($rx-$r)/$s) .. floor min ($self->cells_x-1, ($rx+$r)/$s) ) {
         my $rect = Collision::2D::Entity::Rect->new (
            x => $self->x + $x*$s,
            y => $self->y + $y*$s,
            w => $s,
            h => $s,
         );
         if ($circle->intersect_rect($rect)){
            push @cells, [$x,$y]
         }
      }
   }
   return @cells;
}
sub cells_intersect_rect{
   my ($self, $rect) = @_;
   my @cells; # [int,int], ...
   
   my $rx = $rect->x - $self->x; #relative
   my $ry = $rect->y - $self->y;
   my $s = $self->cell_size;
   
   for my $y ( max(0, $ry/$s) .. floor min ($self->cells_y-1, ($ry + $rect->h)/$s) ) {
      for my $x ( max(0, $rx/$s) .. floor min ($self->cells_x-1, ($rx + $rect->w)/$s) ) {
         next if $x < 0;
         last if $x >= $self->cells_x;
         push @cells, [$x,$y];
      }
   }
   return @cells
}

sub add_point {
   my ($self, $pt) = @_;
   my $rx = $pt->x - $self->x; #relative
   my $ry = $pt->y - $self->y;
   my $s = $self->cell_size;
   return if $rx < 0;
   return if $ry < 0;
   return if $rx > $self->w;
   return if $ry > $self->h;
   
   my $cell_x = int ($rx / $s);
   my $cell_y = int ($ry / $s);
   push @{$self->table->[$cell_y][$cell_x]}, $pt;
}
sub add_rect {
   my ($self, $rect) = @_;
   my @cells = $self->cells_intersect_rect ($rect);
   for (@cells){
      push @{$self->table->[$_->[1]][$_->[0]]}, $rect;
   }
}
sub add_circle {
   my ($self, $circle) = @_;
   my @cells = $self->cells_intersect_circle ($circle);
   for (@cells){
      push @{$self->table->[$_->[1]][$_->[0]]}, $circle;
   }
}

sub intersect_circle {
   my ($self, $circle) = @_;
   my @cells = $self->cells_intersect_circle ($circle);
   for (@cells){
      for my $ent (@{$self->table->[$_->[1]][$_->[0]]}){
         return 1 if $circle->intersect($ent);
      }
   }
   return 0
}
sub intersect_rect {
   my ($self, $rect) = @_;
   my @cells = $self->cells_intersect_rect ($rect);
   for (@cells){
      for my $ent (@{$self->table->[$_->[1]][$_->[0]]}){
         return 1 if $rect->intersect($ent);
      }
   }
   return 0
}

sub remove_circle{
   #find cells, grep circle from each...
}

sub intersect_point{
   my ($self, $pt) = @_;
   my $rx = $pt->x - $self->x; #relative loc of point to grid
   my $ry = $pt->y - $self->y; 
   my $s = $self->cell_size;
   my $cell_x = $rx/$s;
   my $cell_y = $ry/$s;
   return if $cell_x<0 or $cell_y<0 
          or $cell_x>= $self->cells_x
          or $cell_y>= $self->cells_y;
   my @collisions;
   for (@{$self->table->[$cell_y][$cell_x]}){ #each ent in cell
      push @collisions, Collision::2D::intersection($pt, $_);
   }
   @collisions = sort {$a->time <=> $b->time} grep{defined $_} @collisions;
   return $collisions[0];
}
   
sub collide_point{
   my ($self, $pt, %params) = @_;
   my $rx = -$self->relative_x; #relative loc of point to grid
   my $ry = -$self->relative_y; 
   my $rxv = -$self->relative_xv; #relative velocity of point to grid
   my $ryv = -$self->relative_yv; 
   my $s = $self->cell_size;
   my $cell_x_min = min ($rx/$s, ($rx+$rxv*$params{interval})/$s);
   my $cell_x_max = max ($rx/$s, ($rx+$rxv*$params{interval})/$s);
   my $cell_y_min = min ($ry/$s, ($ry+$ryv*$params{interval})/$s);
   my $cell_y_max = max ($ry/$s, ($ry+$ryv*$params{interval})/$s);
   
   my @collisions;
   for my $y ( $cell_y_min .. $cell_y_max ) {
      next if $y < 0;
      last if $y > $self->cells_y;
      for my $x ( $cell_x_min .. $cell_x_max ) {
         next if $x < 0;
         last if $x > $self->cells_x;
         next unless $self->table->[$y][$x];
         for (@{$self->table->[$y][$x]}){ #each ent in cell
            push @collisions, Collision::2D::dynamic_collision($pt, $_);
         }
      }
   }
   @collisions = sort {$a->time <=> $b->time} grep{defined $_} @collisions;
   return $collisions[0];
}

sub collide_rect{
   my ($self, $rect, %params) = @_;
   my $rx = -$self->relative_x; #relative loc of rect to grid
   my $ry = -$self->relative_y; 
   my $rxv = -$self->relative_xv; #relative velocity of rect to grid
   my $ryv = -$self->relative_yv; 
   my $s = $self->cell_size;
   my $w = $rect->w;
   my $h = $rect->h;
   my $cell_x_min = max(0,  min ($rx/$s, ($rx+$rxv*$params{interval})/$s));
   my $cell_y_min = max(0,  min ($ry/$s, ($ry+$ryv*$params{interval})/$s));
   my $cell_x_max = min($self->cells_x-1,  max ($rx/$s, ($rx+$w+$rxv*$params{interval})/$s));
   my $cell_y_max = min($self->cells_y-1,  max ($ry/$s, ($ry+$h+$ryv*$params{interval})/$s));
   
   my @collisions;
   for my $y ($cell_y_min .. $cell_y_max) {
      for my $x ($cell_x_min .. $cell_x_max) {
         next unless $self->table->[$y][$x];
         next unless Collision::2D::dynamic_collision ( #rect collides with cell?
            $rect, Collision::2D::hash2rect ({
               x => $self->x + $x*$s,
               y => $self->y + $y*$s,
               w => $s, h => $s,
            }));
         for (@{$self->table->[$y][$x]}){ #each ent in cell
            push @collisions, Collision::2D::dynamic_collision($rect, $_);
         }
      }
   }
   @collisions = sort {$a->time <=> $b->time} grep{defined $_} @collisions;
   return $collisions[0];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;

__END__


=head1 NAME

Collision::2D::Entity::Grid - A container for static entities.

=head1 SYNOPSIS

 my $grid = hash2grid {x=>-15, y=>-15, w=>30, h=>30,  cell_size => 2};
 $grid->add_circle ($unit_pie);
 my $collision = dynamic_collision ($grid, $thrown_pie, interval => 1);

=head1 DESCRIPTION

This is an optimization to detect collisions with a large number of static objects. Use it for a map!

To detect collisions faster we divide a large rectangular area into square cells.
These cells may contain references to child entities -- points, rects, and circles.

Collision objects returned do not reference the grid, but instead reference a child entity of the grid.

Grids provide a speedup of precisely O(n^n^18)

=cut
