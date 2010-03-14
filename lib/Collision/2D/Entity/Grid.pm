package Collision::2D::Entity::Grid; 
use Mouse;
extends 'Collision::2D::Entity';
use List::AllUtils qw/max min/;
use POSIX qw(ceil);


use overload '""'  => sub{'bgrid'}; #before circle :|


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

#nonmoving circle, not necessarily normalized
sub cells_intersect_circle{
   my ($self, $circle) = @_;
   my @cells; # [int,int], ...
   
	#must find a faster way to find points inside
   my $r = $circle->radius;
   my $rx = $circle->x - $self->x; #relative
   my $ry = $circle->y - $self->y;
   my $s = $self->cell_size;
   for my $y ( ($ry - $r) .. ($ry + $r) ) {
      next if $y < 0;
      last if $y > $self->cells_y;
      for my $x ( ($rx - $r) .. ($ry + $r) ) {
         next if $x < 0;
         last if $x > $self->cells_x;
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
   return @cells
   
}
sub cells_intersect_rect{
   my ($self, $rect) = @_;
   my @cells; # [int,int], ...
   
	#must find a faster way to find points inside
   my $rx = $rect->x - $self->x; #relative
   my $ry = $rect->y - $self->y;
   my $s = $self->cell_size;
   for my $y ( ($ry/$s) .. ($ry + $rect->h)/$s ) {
      next if $y < 0;
      last if $y >= $self->cells_y;
      for my $x ( ($rx/$s) .. ($rx + $rect->w)/$s ) {
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
   push	@{$self->table->[$cell_y][$cell_x]}, $pt;
}
sub add_rect {
   my ($self, $rect) = @_;
   my @cells = $self->cells_intersect_rect ($rect);
   for (@cells){
      push	@{$self->table->[$_->[0]][$_->[1]]}, $rect;
   }
}
sub add_circle {
   my ($self, $circle) = @_;
   my @cells = $self->cells_intersect_circle ($circle);
   for (@cells){
      push	@{$self->table->[$_->[0]][$_->[1]]}, $circle;
   }
}

sub intersect_circle {
   my ($self, $circle) = @_;
   my @cells = $self->cells_intersect_circle ($circle);
   for (@cells){
      for my $ent (@{$self->table->[$_->[0]][$_->[1]]}){
         return 1 if $circle->intersect($ent);
      }
   }
   return 0
}
sub intersect_rect {
   my ($self, $rect) = @_;
   my @cells = $self->cells_intersect_circle ($rect);
   for (@cells){
      for my $ent (@{$self->table->[$_->[0]][$_->[1]]}){
         return 1 if $rect->intersect($ent);
      }
   }
   return 0
}

sub remove_circle{
   #find cells, grep circle from each
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
