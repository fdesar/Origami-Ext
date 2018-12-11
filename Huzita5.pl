#!/usr/bin/perl


#########################################################################
#                                                                       #
# This Perl program is copyrigh 2018, François Désarménien              #
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
use OriMath;

use Huzita5;

my($origami)=Origami->new(@ARGV);
#my($origami)=Origami->new(@argv);

my(@segs)=$origami->Segments();

    @segs == 0
and die gettext("No segment selected.")."\n";

    @segs > 1
and die gettext("Only one segment should be selected.")."\n";

    scalar(@{$segs[0]}) == 4
or  die gettext("The selected segment must be made of exactly 4 points.")."\n";


my($huzita)=Huzita5->new($segs[0][0], $segs[0][1], [@{$segs[0]}[2,3]]);

my(@solutions)=$huzita->Solution();

    @solutions > 1
and warn sprintf(gettext("Warning : %d folds are possible!")."\n",scalar(@solutions));

for my $s (@solutions) {
  $origami->AddGuide($s->[0]);
      $origami->GetVar('proj') eq 'true'
  and $origami->AddPath($s->[1], $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));
}

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();

