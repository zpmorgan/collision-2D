package Collision::Util::Dynamic;
use warnings;
use strict;
use Collision::Util::Collision;
use Collision::Util::Entity;
use Collision::Util::Entity::Point;
use Collision::Util::Entity::Rect;
use Collision::Util::Entity::Circle;

BEGIN {
   require Exporter;
   our @ISA = qw(Exporter);
   our @EXPORT_OK = qw( 
      dynamic_collision
      hash2point hash2rect
      obj2point  obj2rect
      hash2circle obj2circle
      normalize_vec
   );
   our %EXPORT_TAGS = (
      all => \@EXPORT_OK,
      #std => [qw( check_contains check_collision )],
   );
}

sub dynamic_collision{
   my ($ent1, $ent2, %params) = @_;
   $params{interval} //= 1;
   
   #if $obj2 is an arrayref, do this for each thing in @$obj
   # and return all collisions, starting with the closest
   if (ref $ent2 eq 'ARRAY'){
      my @collisions = map {dynamic_collision($ent1,$_,%params)} @$ent2;
      return sort{$a<=>$b} grep{defined$_} @collisions;
   }
   
   #now, we sort by package name. This is so we can find specific routine in predictable namespace.
   #for example, p comes before r, so point-rect collisions are at $point->collide_rect
   ($ent1, $ent2) = sort { "$a" cmp "$b" } ($ent1, $ent2);
   my $method = "collide_$ent2";
   
   $ent1->normalize($ent2);
   my $collision = $ent1->$method($ent2, %params);
   
   return $collision;
}

sub normalize_vec{
   my ($x,$y) = @{shift()};
   my $r = sqrt($x**2+$y**2);
   return [$x/$r, $y/$r]
}

sub hash2point{
   my $hash = shift;
   return Collision::Util::Entity::Point->new (
      x=>$hash->{x},
      y=>$hash->{y},
      xv=>$hash->{xv} || 0,
      yv=>$hash->{yv} || 0,
   );
}
sub hash2rect{
   my $hash = shift;
   return Collision::Util::Entity::Rect->new (
      x=>$hash->{x},
      y=>$hash->{y},
      xv=>$hash->{xv} || 0,
      yv=>$hash->{yv} || 0,
      h=>$hash->{h},
      w=>$hash->{w},
   )
}
sub obj2point{
   my $obj = shift;
   return Collision::Util::Entity::Point->new (
      x=>$obj->x,
      y=>$obj->y,
      xv=>$obj->xv || 0,
      yv=>$obj->yv || 0,
      h=>$obj->h,
      w=>$obj->w,
   )
}
sub obj2rect{
   my $obj = shift;
   return Collision::Util::Entity::Rect->new (
      x=>$obj->x,
      y=>$obj->y,
      xv=>$obj->xv || 0,
      yv=>$obj->yv || 0,
      h=>$obj->h,
      w=>$obj->w,
   )
}

sub hash2circle{
   my $hash = shift;
   return Collision::Util::Entity::Circle->new (
      x=>$hash->{x},
      y=>$hash->{y},
      xv=>$hash->{xv} || 0,
      yv=>$hash->{yv} || 0,
      radius => $hash->{radius} || 1,
   )
}

sub obj2circle{
   my $obj = shift;
   return Collision::Util::Entity::Circle->new (
      x=>$obj->x,
      y=>$obj->y,
      xv=>$obj->xv || 0,
      yv=>$obj->yv || 0,
      radius => $obj->radius || 1,
   )
   
}

q|positively|
