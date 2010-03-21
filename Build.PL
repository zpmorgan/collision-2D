#!/usr/bin/perl
use strict;
use Module::Build;

my $builder = Module::Build->new(
   module_name       => 'Collision::2D',
   license           => 'perl',
   dist_author       => 'Zach Morgan <zpmorgan@cpan.org>',
   dist_version_from => 'lib/Collision/2D.pm',
   abstract_from     => 'lib/Collision/2D.pm',
   requires          => {
      'Test::More' => 0,
      'Mouse' => 0,
      'Test::Number::Delta' => 0,
      'List::AllUtils' => 0,
      'POSIX' => 0,
      'Set::Object' => 0,
   },
   #create_makefile_pl => 'traditional', any reason?
);

$builder->create_build_script();
