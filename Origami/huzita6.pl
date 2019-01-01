#!/usr/bin/perl


#########################################################################
#                                                                       #
# This program is copyrigh 2018, François Désarménien                   #
#                                                                       #
# LICENCE : this Free Software : you may use it and distribute it under #
#           the terms of the GNU GPLv2 licence or either the terms of   #
#           the Inkcape license itself.                                 #
#                                                                       #
#########################################################################

use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

my($origami)=Origami->new(@ARGV);
#my($origami)=Origami->new(@argv);

my(@segs)=$origami->Segments();

    (@segs != 1 or scalar(@{$segs[0]}) != 6)
and die gettext("ONE segment made of SIX points should be selected.")."\n";

my($p1)=$segs[0][0];
my($p2)=$segs[0][3];
my($seg1)=[@{$segs[0]}[1,2]];
my($seg2)=[@{$segs[0]}[4,5]];
my($pb1, $pb2);
my($tan, @sol);

# Sanity check
sub SanityCheck {
  my($d1)=OriMath::EqLine($seg1);
  my($d2)=OriMath::EqLine($seg2);

  # focuses must be distinct
      OriMath::DistinctPoints($p1, $p2)
  or  die gettext("P1 and P2 should be distinct.")."\n";

  # Directrix 1 must be made of distinct points
      OriMath::DistinctPoints($seg1->[0], $seg1->[1])
  or  die gettext("L1 should be made of distinct points.")."\n";

  # Directrix 2 must be made of distinct points
      OriMath::DistinctPoints($seg2->[0], $seg2->[1])
  or  die gettext("L2 should be made of distinct points.")."\n";

  # P1 should not be too near to directrix D1
      abs($d1->[0]*$p1->[0]+$d1->[1]*$p1->[1]+$d1->[2]) < 1e-5
  and die gettext("Point P1 should not be on line L1.")."\n";

  # P2 should not be too near to directrix D2
      abs($d2->[0]*$p2->[0]+$d2->[1]*$p2->[1]+$d2->[2]) < 1e-5
  and die gettext("Point P2 should not be on line L2.")."\n";
}

# check input segment for coherency
SanityCheck();

# Input points are coherent so now let's go

# Compute parabolas and common tangents
$pb1=OriMath::Parabola->new($p1, $seg1);
$pb2=OriMath::Parabola->new($p2, $seg2);
$tan=$pb1->Tangents($pb2);

# Keep only foldable solution(s) if it/they exist(s)
for my $tg (@$tan) {
  my($pj1, $pj2);

          $pj1=OriMath::Projection($p1,$tg,$seg1)
      and $pj2=OriMath::Projection($p2,$tg,$seg2)
  or  next;
  push(@sol, [ $tg, [$pj1, $pj2] ]);
}

    @sol == 0
and warn gettext("No solution.")."\n";

    @sol > 1
and warn sprintf(gettext("Warning : %d folds are possible!")."\n",scalar(@sol));

# Draw guides and eventually projections for foldable solutions
for my $sol (@sol) {
  my($tg)=$sol->[0];
  my($pj1)=$sol->[1][0];
  my($pj2)=$sol->[1][1];
  my($orig)=OriMath::MidPoint(@$pj1);

  $origami->AddGuide(OriMath::Vec->new()->FromLine($tg)->ToSeg($orig));

      $origami->GetVar('proj') eq 'true'
  and do {
    $origami->AddPath($pj1, $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));
    $origami->AddPath($pj2, $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));
  };
}

# Printout some debbuging info
#    $origami->GetVar('debug') eq 'true'
#and do {
#  warn $pb1->PrintInfo("P1 -> D1");
#  warn $pb2->PrintInfo("P2 -> D2");
#  warn "Tangent(s) found:\n";
#      @$tan
#  or  warn "none\n";
#  for(my $i=0; $i<@$tan; ++$i) {
#    warn sprintf("Tg(%d): [ %.7f, %.7f, %.7f ]\n", $i, @{$tan->[$i]});
#  }
#  warn "---------------\nSolution(s):\n";
#      @sol
#  or  warn "none\n";
#  for(my $i=0; $i<@sol; ++$i) {
#    warn sprintf("Tg(%d): [ %.7f, %.7f, %.7f ]\n", $i, @{$sol[$i][0]});
#    warn sprintf("projections: [ [ %.7f, %.7f ], [ %.7f, %.7f ] ] and [ [ %.7f, %.7f ], [ %.7f, %.7f ] ]\n",
#                 @{$sol[$i][1][0][0]}, @{$sol[$i][1][0][1]},
#                 @{$sol[$i][1][1][0]}, @{$sol[$i][1][1][1]});
#
#  }
#  warn "---------------\n";
#};

# Draw parabolas if required by user
    $origami->GetVar('drawp') eq 'true'
and do {
  $origami->AddQBPath($pb1->BezierQuad($origami->GetVar('pscale')));
  $origami->AddQBPath($pb2->BezierQuad($origami->GetVar('pscale')));
};

# Remove segments only if soution(s) have been found
    @sol>0
and $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

# Done
$origami->Apply();

