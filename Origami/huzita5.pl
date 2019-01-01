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

    (@segs != 1 or scalar(@{$segs[0]}) != 4)
and die gettext("ONE segment made of FOUR points should be selected.")."\n";


my($p1)=$segs[0][0];
my($f)=$segs[0][1];
my($seg)=[@{$segs[0]}[2,3]];

sub SanityCheck {
  my($d);

  # Check that all points are distinct
      OriMath::DistinctPoints(@{$segs[0]})
  or  die gettext("All points should be distinct.")."\n";
  # Compute line from segment D
  $d=OriMath::EqLine($seg);
  # P2 shouldn't be too near to its bissectrix
      abs($d->[0]*$f->[0]+$d->[1]*$f->[1]+$d->[2]) < 1e-5
  and die gettext("Point P2 should not be on line L.")."\n";
}


# Sanity check for input segment
SanityCheck();

# All point are coherent so let's go

# Compute parabola for P2-D and its tangent(s) through point P1
my($p)=OriMath::Parabola->new($f, $seg);
my($tan)=$p->Tangents($p1);
my(@sol);

# Keep only foldable solution(s) if it/they exist(s)
for my $tg (@$tan) {
  my($pj);
      $pj=OriMath::Projection($f,$tg,$seg)
  or  next;
  push(@sol, [ $tg, $pj ]);
}

    @sol == 0
and warn gettext("No solution.")."\n";

# Warn if there's more than one solution
    @sol > 1
and warn sprintf(gettext("Warning : %d folds are possible!")."\n",scalar(@sol));

# Display guide and projections if requested
for my $sol (@sol) {
    my($tg,$pj)=@$sol;

  $origami->AddGuide(OriMath::Vec->new()->FromLine($tg)->ToSeg($p1));

      $origami->GetVar('proj') eq 'true'
  and $origami->AddPath($pj, $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));
}

# Display if required debugging informations
#    $origami->GetVar('debug') eq 'true'
#and do {
#  warn sprintf("P1:(%.7f, %.7f)\n", @$p1);
#  warn $p->PrintInfo("P2 -> D");
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
#    warn sprintf("Projection: [ [ %.7f, %.7f ], [ %.7f, %.7f ] ]\n", @{$sol[$i][1][0]}, @{$sol[$i][1][1]});
#  }
#  warn "---------------\n";
#};

# Draw P2-D parabola if requested
    $origami->GetVar('drawp') eq 'true'
and $origami->AddQBPath($p->BezierQuad($origami->GetVar('pscale')));

# Remove construction segments if required and at least a solution as been found
    @sol > 0
and $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

# Done
$origami->Apply();

