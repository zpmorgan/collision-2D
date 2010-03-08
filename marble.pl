#!/usr/bin/perl
use warnings; use strict;

=pod

=head1 NAME Shooter.pl

A demonstration to demonstrate a marble colliding with a staircase. Derived from kthakore's shooter.pl.

=cut

use lib 'lib';
use Collision::2D ':all';
use SDL;
use SDL::Video;
use SDL::Surface;;
use SDL::Event;
use SDL::Rect;
use SDL::Color;
use SDL::GFX::Primitives;

use Carp;

=comment 
use SDL::Events;
use SDL::Time;
use Data::Dumper;

=cut


#Initing video
#Die here if we cannot make video init
croak 'Cannot init video ' . SDL::get_error()
  if ( SDL::init(SDL_INIT_VIDEO) == -1 );

#Make our display window
#This is our actual SDL application window
my $app = SDL::Video::set_video_mode( 800, 500, 32, SDL_SWSURFACE );

croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($app);

#constants
my $grav = 1;
my $dot_size = 4; #even though it's a point, it has to be visible

#the things that move & collide
my @crates = map {random_crate()} (1..4);
my @dots = map {random_dot()} (1..4);
my @lamps = map {random_lamp()} (1..2);
my @marbles = map {random_marble()} (1..3);
#my $marble_surf = init_marble_surf();
#my $crate_surf = init_crate_surf();


# Get an event object to snapshot the SDL event queue
my $event = SDL::Event->new();
my $cont=1;
#Our level game loop
while ( $cont ) {
   
   
   while ( SDL::Events::poll_event($event) )
   {    #Get all events from the event queue in our event
      if ($event->type == SDL_QUIT)
      {
         $cont = 0 
      }
   }
   
   for my $marble (@marbles){
      my $interval = 1;
      $marble->{y} = -60 if $marble->{y} > 560;#wrap y
      $marble->{y} = 560 if $marble->{y} < -60;#wrap y
      $marble->{yv} = 40 if $marble->{yv} > 40; #y speed limit
      $marble->{yv} = -40 if $marble->{yv} < -40; #y speed limit
      $marble->{xv} = 40 if $marble->{xv} > 40; #x speed limit
      $marble->{xv} = -40 if $marble->{xv} < -40; #x speed limit
      $marble->{x} = -60 if $marble->{x} > 960;#wrap x
      $marble->{x} = 960 if $marble->{x} < -60;#wrap x
      
      $marble->{yv} += $grav;
      my @collisions = map {dynamic_collision (hash2circle ($marble), hash2rect ($_), interval=>$interval)} @crates;
      push @collisions, map {dynamic_collision (hash2circle ($marble), hash2point ($_), interval=>$interval)} @dots;
      push @collisions, map {dynamic_collision (hash2circle ($marble), hash2circle ($_), interval=>$interval)} @lamps;
      push @collisions, #collide with other marbles too
                 map {dynamic_collision (hash2circle ($marble), hash2circle ($_))} 
                 grep {$_ != $marble}
                 @marbles;
      @collisions = grep {$_ and $_->time} @collisions;
      @collisions = sort {$a->time <=> $b->time} @collisions;
      my $collision = $collisions[0];
      if ($collision) {
         die 'aaah' unless $collision->axis;
         $marble->{y} += $marble->{yv} * $collision->time;
         $marble->{x} += $marble->{xv} * $collision->time; #0..
         my $bvec = $collision->bounce_vector;
         $marble->{xv} = $bvec->[0];
         $marble->{yv} = $bvec->[1];
         $interval -= $collision->time; #leftover frame interval
         redo;
      }
      else {
         $marble->{y} += $marble->{yv}*$interval;
         $marble->{x} += $marble->{xv}*$interval;
      }
   }
   SDL::Video::fill_rect(
      $app,
      SDL::Rect->new( 0, 0, 800, 500 ),
      SDL::Video::map_RGB( $app->format, 0,0,0 )
   );
   for my $crate (@crates){
      SDL::Video::blit_surface(
         $crate->{surf},
         SDL::Rect->new( 0, 0, $crate->{w}, $crate->{h}),
         $app,
         SDL::Rect->new(
            $crate->{x} , $crate->{y},
            $crate->{w} , $crate->{h},
         )
      )
   }
   
   for my $dot (@dots){
      SDL::Video::blit_surface(
         $dot->{surf},
         SDL::Rect->new( 0, 0, $dot_size, $dot_size),
         $app,
         SDL::Rect->new(
            $dot->{x}-2 , $dot->{y}-2,
            $dot_size, $dot_size,
         )
      )
   }
   
   for my $marble (@marbles,@lamps){
      SDL::Video::blit_surface(
         $marble->{surf},
         SDL::Rect->new( 0, 0, 2*$marble->{radius}, 2*$marble->{radius}),
         $app,
         SDL::Rect->new(
            $marble->{x} - $marble->{radius},
            $marble->{y} - $marble->{radius},
            2*$marble->{radius},
            2*$marble->{radius},
         )
      );
   }
   
   #Update the entire window
   #This is one frame!
   SDL::Video::flip($app);
}



sub random_dot{
   my $dot = {x=>30+rand(740), y=>200+rand(250), xv=>0, yv=>0};
   $dot->{surf} = init_dot_surf($dot);
   return $dot
}
sub random_lamp{
   my $lamp = {x=>100+rand(600), y=>200+rand(250), radius => 10+rand(60), xv=>0, yv=>0};
   $lamp->{surf} = init_marble_surf($lamp);
   return $lamp
}
sub random_marble{
   my $marble = {x=>100+rand(600), y=>100+rand(300), radius=>30+rand(50), xv=>0, yv=>0};
   $marble->{surf} = init_marble_surf($marble);
   return $marble
}
sub random_crate{
   my $crate = {x=>rand(700), y=>150+rand(300), w=>rand(50)+50, h=>rand(50)+50};
   $crate->{surf} = init_crate_surf($crate);
   return $crate
}


sub init_dot_surf {
   my $dot = shift;
   my $surf =
      SDL::Surface->new( SDL_SWSURFACE, $dot_size,$dot_size, 32, 0, 0, 0,
      255 );
   SDL::Video::fill_rect(
      $surf,
      SDL::Rect->new( 0, 0, $dot_size,$dot_size ),
      SDL::Video::map_RGB( $app->format, map {rand( 0x100 - 0x44 ) + 0x44} (1..3) )
   );
   return $surf;
}
sub init_crate_surf {
   my $crate = shift;
   my $w = $crate->{w};
   my $h = $crate->{h};

   my $surf =
      SDL::Surface->new( SDL_SWSURFACE, $w, $h, 32, 0, 0, 0,
      255 );

   SDL::Video::fill_rect(
      $surf,
      SDL::Rect->new( 0, 0, $w, $h ),
      SDL::Video::map_RGB( $app->format, 200, 200, 200 )
   );
   return $surf;
}

#from shooter.pl
# Make an initail surface for the marble
# so we only use it once
sub init_marble_surf {
   my $marble = shift;
   my $size = $marble->{radius}*2;

   #make a surface based on the size
   my $particle =
      SDL::Surface->new( SDL_SWSURFACE, $size + 15, $size + 15, 32, 0, 0, 0,
      255 );

      SDL::Video::fill_rect(
         $particle,
         SDL::Rect->new( 0, 0, $size + 15, $size + 15 ),
         SDL::Video::map_RGB( $app->format, 0,0,0 )
      );

   #draw a circle on it with a random color
   SDL::GFX::Primitives::filled_circle_color( $particle, $size / 2, $size / 2,
      $size / 2 - 2,
      rand_color() );

   SDL::GFX::Primitives::aacircle_color( $particle, $size / 2, $size / 2,
      $size / 2 - 2, 0x000000FF );
   SDL::GFX::Primitives::aacircle_color( $particle, $size / 2, $size / 2,
      $size / 2 - 1, 0x000000FF );

   SDL::Video::display_format($particle);
   my $pixel = SDL::Color->new( 60, 60, 60 );
   SDL::Video::set_color_key( $particle, SDL_SRCCOLORKEY, $pixel );

   return $particle;
}

#Gets a random color for our particle
sub rand_color {
    my $r = rand( 0x100 - 0x44 ) + 0x44;
    my $b = rand( 0x100 - 0x44 ) + 0x44;
    my $g = rand( 0x100 - 0x44 ) + 0x44;

    return ( 0x000000FF | ( $r << 24 ) | ( $b << 16 ) | ($g) << 8 );

}
