package Collision::Util;

use warnings;
use strict;

our $VERSION = '0.01';



42;
__END__
=head1 NAME

Collision::Util - A selection of general collision detection utilities

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Collision::Util ':std';

    my $foo = Collision::Util->new();
    ...

=head1 DESCRIPTION

Collision::Util contains sets of several functions to help you detect 
collisions in your programs. While it focuses primarily on games, you can use 
it for any application that requires collision detection.

=head1 EXPORTABLE SETS

Collision::Util doesn't export anything by default. You have to explicitly 
define function names or one of the available helper sets.

=head2 :std

=head2 :rect

=head2 :circ

=head2 :dot

=head2 :all


=head1 MAIN UTILITIES

=head2 inside ($source, $target)

=head2 inside ($source, [ $target1, $target2, $target3, ... ])

Returns the index of target item (starting from 1, so you always get a 'true' value) when the $target is completely inside the $source. Otherwise returns undef.

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

