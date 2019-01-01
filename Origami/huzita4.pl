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

use Math::Trig qw/pi/;

use Origami;

my($origami)=Origami->new(@ARGV);

my(@segs)=$origami->Segments();

    (@segs != 1 or scalar(@{$segs[0]}) != 3)
and die gettext("ONE segment made of THREE points should be selected.")."\n";

    OriMath::DistinctPoints(@{$segs[0]})
or  die gettext("All points should be distinct.")."\n";

my($p)=$segs[0][0];
my($seg)=[@{$segs[0]}[1..2]];
my($d)=OriMath::EqLine($seg);
my($sol);

$sol=OriMath::Projection($p, $d, $seg);

    $sol
or  warn gettext("No solution.")."\n";

    $sol
and do {
  $origami->AddGuide($sol);

      $origami->GetVar('clean') eq 'true'
  and $origami->RemoveSelection();
};

#    $sol
#and $origami->GetVar('debug') eq 'true'
#and do {
#    my($d)=OriMath::EqLine($sol);
#};

$origami->Apply();

