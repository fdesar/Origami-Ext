use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

use Math::Trig;

my($origami)=Origami->new(@ARGV);
my(@segs)=$origami->Segments();

    (@segs != 1 or scalar(@{$segs[0]} != 5))
and die gettext("ONE segment made of FIVE points should be selected.")."\n";


my($seg1)=[ @{$segs[0]}[0,1] ];
my($f)=$segs[0][2];
my($seg2)=[ @{$segs[0]}[3,4] ];


sub SanityCheck {
  my($d);
  # Check that all points are distinct
      OriMath::DistinctPoints(@{$segs[0]})
  or  die gettext("All points should be distinct.")."\n";
  # Compute line from segment D2
  $d=OriMath::EqLine($seg2);
  # If P2 is on its directrix D2, the parabola cannot not exists
      abs($d->[0]*$f->[0]+$d->[1]*$f->[1]+$d->[2]) < 1e-5
  and die gettext("Point P2 should not be on line L2.")."\n";
}



SanityCheck();

# Now that we know all points are valid, do the job

my($d1)=OriMath::EqLine($seg1);
my($d2)=OriMath::EqLine($seg2);
my($p)=OriMath::Parabola->new($f,$seg2);
my($v, $dr, $pseg);


# Compute v, the vector perpendicular to line L1
$v=OriMath::Vec->new()->FromSeg(@$seg1)->Rotate(pi/2)->Unit();

# Get the solution if it exists :
# if vector v is // to directrix (line L1 // L2)
#    or tangent dr to vector v is // to directrix
#    or projection is outside segment D2
# then there is no solution
    (     $dr=$p->Tangents($v)->[0]
      and $pseg=OriMath::Projection($f,$dr,$seg2))
or  warn gettext("No solution.")."\n";

# Check if dr crosses L1 inside seg1
    $pseg
and do {
  my($po)=OriMath::LineIntersect($d1, $dr);
      not OriMath::PointInSegment($po, $seg1)
  and do {
    $pseg=undef;
    warn gettext("No solution.")."\n";
  }; 
};

# if defined(pseg) there is a solution which is line dr perpendicular
# to D1 and projection pseg of f to D2, so draw them
    $pseg
and do {
  my($p1,$p2);

  # Get intersection points of solution dr with D1 and D2
  $p1 = OriMath::LineIntersect($d1, $dr);
  $p2 = OriMath::LineIntersect($d2, $dr);

  $origami->AddGuide([$p1, $p2]);

      $origami->GetVar('proj') eq 'true'
  and do {
    $origami->AddPath($pseg, $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));
  };

      $origami->GetVar('clean') eq 'true'
  and $origami->RemoveSelection();

};

# Display if required debugging informations
#    $origami->GetVar('debug') eq 'true'
#and do {
#  warn sprintf("P:(%.7f, %.7f)\n", @$f);
#  warn $p->PrintInfo("P2 -> D2");
#  warn "Tangent found:\n";
#  warn $dr ? sprintf("Tg: [ %.7f, %.7f, %.7f ]\n", @$dr) : "none\n";
#  warn "---------------\nSolution:\n";
#  warn $pseg ? sprintf("Projection: [ [ %.7f, %.7f ], [ %.7f, %.7f ] ]\n", @{$pseg->[0]}, @{$pseg->[1]}) : "none\n";
#  warn "---------------\n";
#};



# Draw parabola if requested
  $origami->GetVar('drawp') eq 'true'
and $origami->AddQBPath($p->BezierQuad($origami->GetVar('pscale')));

$origami->Apply();

