package Collision::Util::Grid;
use Mouse;
use File::Slurp qw/slurp/; 
use List::AllUtils qw/max/;


# table where we store if the cell is filled or not
has table => (
	isa => 'ArrayRef[ArrayRef[Any]]',
	is  => 'rw',
	lazy => 1,
	default => sub {
		[];
	},
);

has $_      => (
	isa => 'Num',
	is  => 'rw',
	default => 0,
) for qw/width height/;

# cells will be squares of this size
has cell_size => ( 
	isa => 'Num',
	is  => 'rw',
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
		$self->width(max($self->width,~~@line_));
	};
	$self->height($linenum);
}



1;
