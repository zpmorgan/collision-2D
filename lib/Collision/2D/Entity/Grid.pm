package #hide from CPAN indexer, for now
   Collision::2D::Entity::Grid; 
use Mouse;
extends 'Collision::2D::Entity';
use File::Slurp qw/slurp/; 
use List::AllUtils qw/max/;



=pod

=head1 DESCRIPTION

To detect collisions faster we'll write a Grid on which we'll mark objects (as well as the grid itself).
Collisions can occur with other objects that are marked on the grid or with the grid itself.
Should multiple collisions occur collide_with_grid will return the earliest one.
On one cell of the 2D table below , there can be multiple Entities.

=cut

# table where we store if the cell is filled or not
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

# granularity; cells will be squares of this size
has cell_size => ( 
	isa => 'Num',
	is  => 'ro',
);


sub serialize {
	my ($self) = @_;
	
	join(
		"\n",
		map {
			join('', @$_);
		} @{$self->table}
	);
}



sub init_from_file {
	my ($self,$file) = @_;
	my @lines = split /\n/,slurp($file);
	my $linenum=0;
	for my $line(@lines) {
		my @line_ = split //,$line;
		$self->table->[$linenum] = \@line_;
		$linenum++;
		$self->w(max($self->width,~~@line_));
	};
	$self->h($linenum);
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
