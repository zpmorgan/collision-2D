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


#the things that move & collide
my $crate = {x=>100, y=>100, h=>100, w=>100};
my $marble = {x=>220, y=>400, radius=>90, xv=>0, yv=>0};
my $grav = 5;
my $marble_surf = init_marble_surf();
my $crate_surf = init_crate_surf();


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
   
   $marble->{yv} -= $grav;
   my $collision = dynamic_collision (hash2circle ($marble), hash2rect ($crate));
   if ($collision) {
      die 'aaah' unless $collision->axis;
      $marble->{y} += $marble->{yv} * $collision->time;
      $marble->{x} += $marble->{xv} * $collision->time; #0..
      my $bvec = $collision->bounce_vector;
      $marble->{xv} = $bvec->[0];
      $marble->{yv} = $bvec->[1];
      $marble->{y} += $marble->{yv} * (1-$collision->time); #leftover frame interval
      $marble->{x} += $marble->{xv} * (1-$collision->time); #leftover frame interval
   }
   else {
      $marble->{y} += $marble->{yv};
      $marble->{x} += $marble->{xv};
   }
   
   
   SDL::Video::blit_surface(
      $crate_surf,
      SDL::Rect->new( 0, 0, $crate->{w}, $crate->{h}),
      $app,
      SDL::Rect->new(
         $crate->{x} , $crate->{y},
         $crate->{w} , $crate->{h},
      )
   );
   
   SDL::Video::blit_surface(
      $marble_surf,
      SDL::Rect->new( 0, 0, 2*$marble->{radius}, 2*$marble->{radius}),
      $app,
      SDL::Rect->new(
         $marble->{x} - $marble->{radius},
         $marble->{y} - $marble->{radius},
         2*$marble->{radius},
         2*$marble->{radius},
      )
   );
   
   
   #Update the entire window
   #This is one frame!
   SDL::Video::flip($app);
}


sub init_crate_surf {
    my $size = $crate->{w};
   
    my $surf =
      SDL::Surface->new( SDL_SWSURFACE, $size + 15, $size + 15, 32, 0, 0, 0,
        255 );
        
    SDL::Video::fill_rect(
        $surf,
        SDL::Rect->new( 0, 0, $size, $size ),
        SDL::Video::map_RGB( $app->format, 60, 60, 60 )
    );
   return $surf;
}

#from shooter.pl
# Make an initail surface for the marble
# so we only use it once
sub init_marble_surf {
    my $size = $marble->{radius}*2;

    #make a surface based on the size
    my $particle =
      SDL::Surface->new( SDL_SWSURFACE, $size + 15, $size + 15, 32, 0, 0, 0,
        255 );

    SDL::Video::fill_rect(
        $particle,
        SDL::Rect->new( 0, 0, $size + 15, $size + 15 ),
        SDL::Video::map_RGB( $app->format, 60, 60, 60 )
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
