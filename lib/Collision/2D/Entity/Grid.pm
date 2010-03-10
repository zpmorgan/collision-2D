package Collision::2D::Entity::Grid; 
use Mouse;
extends 'Collision::2D::Entity';
use List::AllUtils qw/max/;



=pod

=head1 DESCRIPTION

To detect collisions faster we'll write a Grid on which we'll mark objects (as well as the grid itself).
Collisions can occur with other objects that are marked on the grid or with the grid itself.
Should multiple collisions occur collide_with_grid will return the earliest one.
On one cell of the 2D table below , there can be multiple Entities.

Grids provide a speedup of precisely O(n^n^18)

=cut

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
         return int( 1 + $_[0]->x / $_[0]->cell_size)
   },
);
has cells_y => (
	isa => 'Int',
	is  => 'ro',
	lazy  => 1,
	default => sub{
         return int( 1 + $_[0]->y / $_[0]->cell_size)
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
sub add_rect {} #todo
sub add_circle {
   my ($self, $circle) = @_;
   my @cells = $self->cells_intersect_circle ($circle);
   for (@cells){
      push	@{$self->table->[$_->[0]][$_->[1]]}, $circle;
   }
}

sub remove_circle{
   #find cells, grep from each
}



no Mouse;
__PACKAGE__->meta->make_immutable();

1;
