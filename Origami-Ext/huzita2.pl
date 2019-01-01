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

    (@segs != 1 or scalar(@{$segs[0]}) != 2)
and die gettext("ONE segment made of TWO points should be selected.")."\n";

my($seg)=$segs[0];

    OriMath::DistinctPoints($seg)
or  die gettext("All points should be distinct.")."\n";

my($p1)=$seg->[0];
my($p2)=$seg->[1];
my($v)=OriMath::Vec->new()->FromSeg(@$seg)->Rotate(pi/2);
my($po)=OriMath::MidPoint($p1, $p2);
my($sol)=$v->ToSeg($po);

$origami->AddGuide($sol);

#    $origami->GetVar('debug') eq 'true'
#and do {
#    my($d)=OriMath::EqLine($sol);
#    warn sprintf("Segment: [%.7f, %.7f] to [%.7f, %.7f]\n", @$p1, , @$p2);
#    warn sprintf("Solution line: [ %.7f, %.7f, %.7f ]\n", @$d);
#};

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();

