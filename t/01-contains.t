
use strict;
use warnings;

package Rect;
  sub new { my $class = shift; return bless {@_}, $class }
  sub x { $_[0]->{x} = $_[1] if $_[1]; return $_[0]->{x} }
  sub y { $_[0]->{y} = $_[1] if $_[1]; return $_[0]->{y} }
  sub w { $_[0]->{w} = $_[1] if $_[1]; return $_[0]->{w} }
  sub h { $_[0]->{h} = $_[1] if $_[1]; return $_[0]->{h} }

package main;

use Test::More tests => 12;

use Collision::Util ':all';

  
my $rect1 = Rect->new( x =>  1, y =>  1, w => 10, h => 10 );
my $rect2 = Rect->new( x =>  5, y =>  8, w =>  4, h =>  1 );
my $rect3 = Rect->new( x => 16, y => 12, w =>  3, h =>  3 );
  
ok(check_contains($rect1, $rect1), 'rect is inside itself');
ok(check_contains($rect1, $rect2), 'rect2 inside rect1');
ok(!check_contains($rect3, $rect1), 'rect1 not inside rect3');

is (check_contains($rect1, [$rect2, $rect3]), 1, 'receiving first index 1');
is (check_contains($rect1, [$rect3, $rect2]), 2, 'receiving first index 2');

my @ret = check_contains($rect1, [$rect2, $rect3]);
is_deeply(\@ret, [1], 'receiving all indexes 1');

@ret = check_contains($rect1, [$rect3, $rect2]);
is_deeply(\@ret, [2], 'receiving all indices 2');

@ret = check_contains($rect1, [$rect2, $rect1, $rect3, $rect2]);
is_deeply(\@ret, [1, 2, 4], 'receiving all indices 3');


@ret = check_contains($rect1, { north => $rect2, south => $rect1, 
                                east  => $rect3, west  => $rect2
                              }
                     );
is(scalar(grep {$_ eq 'north'} @ret), 1, 'rect contains north key' );
is(scalar(grep {$_ eq 'south'} @ret), 1, 'rect contains south key' );
is(scalar(grep {$_ eq 'west' } @ret), 1, 'rect contains west key'  );
is(scalar(grep {$_ eq 'east' } @ret), 0, 'rect contains east key'  );
