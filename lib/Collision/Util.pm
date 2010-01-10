package Collision::Util;

use warnings;
use strict;

our $VERSION = '0.01';



42;
__END__
=head1 NAME

Collision::Util - A selection of general collision detection utilities

=head1 SYNOPSIS

Say you have a class with C<< ->x() >>, C<< ->y() >>, C<< ->w() >>, and 
C<< ->h() >> accessors, like L<< SDL::Rect >> or the one below:

  package Block;
  use Class::XSAccessor {
      constructor => 'new',
      accessors   => [ 'x', 'y', 'w', 'h' ],
  };
  
let's go for a procedural approach:
  
  use Collision::Util ':std';
  
  my $rect1 = Block->new( x =>  1, y =>  1, w => 10, h => 10 );
  my $rect2 = Block->new( x =>  5, y =>  9, w =>  6, h =>  4 );
  my $rect3 = Block->new( x => 16, y => 12, w =>  3, h =>  3 );
  
  check_collision($rect1, $rect2);  # true
  check_collision($rect3, $rect1);  # false
  
  # you can also check if them all in a single run:
  check_collision($rect1, [$rect2, $rect3] );
  
As you might have already realized, you can just as easily bundle collision 
detection into your objects:

  package CollisionBlock;
  use Class::XSAccessor {
      constructor => 'new',
      accessors   => [ 'x', 'y', 'w', 'h' ],
  };
  
  # if your class has the (x, y, w, h) accessors,
  # imported methods will work just like methods!
  use Collision::Util ':std';
  
Then, further in your code:

  my $rect1 = CollisionBlock->new( x =>  1, y =>  1, w => 10, h => 10 );
  my $rect2 = CollisionBlock->new( x =>  5, y =>  9, w =>  6, h =>  4 );
  my $rect3 = CollisionBlock->new( x => 16, y => 12, w =>  3, h =>  3 );
  
  $rect1->check_collision( $rect2 );  # true
  $rect3->check_collision( $rect1 );  # false
  
  # you can also check if them all in a single run:
  $rect1->check_collision( [$rect2, $rect3] );


=head1 DESCRIPTION

Collision::Util contains sets of several functions to help you detect 
collisions in your programs. While it focuses primarily on games, you can use 
it for any application that requires collision detection.

=head1 EXPORTABLE SETS

Collision::Util doesn't export anything by default. You have to explicitly 
define function names or one of the available helper sets below:

=head2 :std

=head2 :rect

=head2 :circ

=head2 :dot

=head2 :all


=head1 MAIN UTILITIES

=head2 inside ($source, $target)

=head2 inside ($source, [ $target1, $target2, $target3, ... ])

  if ( inside($obj1, $obj2) ) {
      # do something
  }
  
  die if inside($hero, \@bullets);

Returns the index (starting from 1, so you always get a 'true' value) of first 
target item completely inside $source. Otherwise returns undef.

  @visible = inside($area, \@enemies);

If your code context wants it to return a list, C<< inside >> will return a 
list of all indices (again, 1-based) completely inside $source. If no 
elements are found, an empty list is returned. 


=head1 USING IT IN YOUR OBJECTS



=head1 AUTHOR

Breno G. de Oliveira, C<< <garu at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-collision-util at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Collision-Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Collision::Util


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Collision-Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Collision-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Collision-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/Collision-Util/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Breno G. de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

