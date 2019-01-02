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

my(@segs)=$origami->Segments();

    (@segs != 1 or scalar(@{$segs[0]}) != 2)
and die gettext("ONE segment made of TWO points should be selected.")."\n";

my($seg)=$segs[0];

    OriMath::DistinctPoints(@{$segs[0]})
or  die gettext("All points should be distinct.")."\n";

$origami->AddGuide($seg);

#    $origami->GetVar('debug') eq 'true'
#and do {
#    my($d)=OriMath::EqLine($seg);
#    warn sprintf("Segment: [%.7f, %.7f] to [%.7f, %.7f]\n", @{$seg->[0]}, , @{$seg->[1]});
#    warn sprintf("Solution line: [ %.7f, %.7f, %.7f ]\n", @$d);
#};

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();

