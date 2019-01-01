#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

use Math::Trig;

my($origami)=Origami->new(@ARGV);
my(@segs)=$origami->Segments();

    (@segs != 1 or (scalar(@{$segs[0]}) != 3 and scalar(@{$segs[0]}) != 4))
and die gettext("ONE segment made of THREE or FOUR points should be selected.")."\n";

    scalar(@{$segs[0]} == 3)
and do {
  push(@{$segs[0]}, $segs[0][2]);
  $segs[0][2]=$segs[0][1];
};

my(@s, @d, @v, @sol);
my($po, $vr);

$s[0]=[ @{$segs[0]}[0,1]];
$s[1]=[ @{$segs[0]}[2,3]];

# Sanity check
    OriMath::DistinctPoints(@{$s[0]})
or  die sprintf(gettext("The two points of line L%s should be distinct.")."\n",'1');
    OriMath::DistinctPoints(@{$s[1]})
or  die sprintf(gettext("The two points of line L%s should be distinct.")."\n",'2');

# Compute lines from segments
$d[0]=OriMath::EqLine(@{$s[0]});
$d[1]=OriMath::EqLine(@{$s[1]});

# Compute vectors from segments
$v[0]=OriMath::Vec->new()->FromSeg(@{$s[0]});
$v[1]=OriMath::Vec->new()->FromSeg(@{$s[1]});


# There are two very distinct cases : segment are or aren't // (or mostly)
if (   OriMath::Equals(-$d[0]->[1]*$d[1]->[0],-$d[1]->[1]*$d[0]->[0])
   or OriMath::IsZero($v[0]->Theta($v[1])))
{ # Lines are //
  my($p1)=OriMath::MidPoint($s[0][0],$s[0][1]);
  my($p2)=OriMath::MidPoint($s[1][0],$s[1][1]);


  $po=OriMath::MidPoint($p1,$p2);
  $vr=OriMath::Vec->new(-$d[0][1],$d[0][0]); # Pick d[0] as vector (could have been d[1])

  push(@sol, $vr);

} else { # Lines are secant

  # First correct segment order if needed
  my $ReorderSegs = sub {
    my($orig)=OriMath::LineIntersect($d[0],$d[1]);
    my(@vo2s);

    # Swap two elements of a list reference
    my $Swap = sub {
      my($list)=shift;

      # rotate right should also work and would be :
      # unshift(@list, pop(@list));

      push(@$list, shift(@$list));

    };

    # First, now we've got the intersection point, check if segments are crossing each other
    # and if so, set po to this point
        (OriMath::PointInSegment($orig, $s[0]) or OriMath::PointInSegment($orig, $s[1]))
    and $po = $orig;

    # then vectors from intersection to first point of segments
    $vo2s[0]=OriMath::Vec->new()->FromSeg($orig,$s[0][0]);
    $vo2s[1]=OriMath::Vec->new()->FromSeg($orig,$s[1][0]);

    for my $i (0..1) { # for each segment

      # if intersect is on segment, Norm==0 so use the other segment point
      #
          OriMath::IsZero($vo2s[$i]->Norm())
      and $vo2s[$i]=OriMath::Vec->new()->FromSeg($orig, $s[$i][1]);  

      # Check if direction of seg is the same as direction of vector theta
      # if > pi/4 => segment is in the wrong way so switch points
      # and recompute d and v
          $vo2s[$i]->Theta($v[$i]) > pi/4
      and do {
        &$Swap($s[$i]);
        $d[$i]=OriMath::EqLine(@{$s[$i]});
        $v[$i]=OriMath::Vec->new()->FromSeg(@{$s[$i]});
      };
    }

    # now v[0] & v[1] are in the correct direction
    # check if Tetha(v[0], v[1]) > pi => switch segs
    #
      $v[0]->Theta($v[1]) > pi
    and do {
      &$Swap(\@s);
      &$Swap(\@d);
      &$Swap(\@v);
    };
  };

  &$ReorderSegs();

  # Now that we know segments are in right order, do the job now

  # Get the bissectrix
  $vr=$v[1]->Rotate(-$v[0]->Theta($v[1])/2);

  # If we got po from ReorderSegs, the two segments instersect
  if(defined($po)) {
    # and f they do not intersect on their common point, the two bissectrix could be folded
    # so warn for double solution and add it
        not OriMath::IsZero(OriMath::PointsDist($s[0][0], $po))
    and not OriMath::IsZero(OriMath::PointsDist($s[0][1], $po))
    and do {
      # Draw the other bissectrix, 90° from the solution found
      push(@sol, $vr->Rotate(pi/2));
    };
  }
  else { 
    # The two segments are totally distinct : 
    # their intersection can be very far if they make a very obtuse angle
    # so compute the origin close to the first segment instead of intersection point
    # for better precision
    my($p1)=$s[0][0];
    my($dr)=OriMath::EqLine($p1, $vr->ToPoint($p1));
    my($dp)=OriMath::Perpendicular($p1,$dr);
    my($p2)=OriMath::LineIntersect($dp, $d[1]);
  
    $po=OriMath::MidPoint($p1, $p2);
  }
  push(@sol, $vr);
}

    @sol == 2
and warn gettext("L1 and L2 cross each other: there are two possible folds.")."\n";

#    $origami->GetVar('debug') eq 'true'
#and do {
#  warn sprintf("Segment 1 : [%.7f, %.7f] to [%.7f, %.7f]\n", @{$s[0][0]}, @{$s[0][1]});
#  warn sprintf("Segment 2 : [%.7f, %.7f] to [%.7f, %.7f]\n", @{$s[1][0]}, @{$s[1][1]});
#  for my $sol (@sol) {
#    my($d)=$sol->ToLine($po);
#    warn sprintf("Solution line : [%.7f, %.7f, %.7f]\n",@$d);
#  }
#};

    @sol > 0
and do { 

  for my $sol (@sol) {
    my($seg)=$sol->ToSeg($po);
    $origami->AddGuide($seg);
  }

      $origami->GetVar('clean') eq 'true'
  and $origami->RemoveSelection();

  $origami->Apply();
};

exit(1);
