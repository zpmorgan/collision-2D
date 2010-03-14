use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Collision::2D',
    AUTHOR              => q{Zach Morgan <zpmorgan@cpan.org>},
    VERSION_FROM        => 'lib/Collision/2D.pm',
    ABSTRACT_FROM       => 'lib/Collision/2D.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Mouse' => 0,
		  'Test::Number::Delta' => 0,
		  'List::AllUtils' => 0,
		  'POSIX' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Collision-2D-*' },
);

BEGIN { require 5.010 }

