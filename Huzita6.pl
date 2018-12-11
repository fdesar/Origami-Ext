#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;
use OriMath;

use Huzita6;

my($origami)=Origami->new(@ARGV);

    $origami->GetVar('debug') eq 'true'
and $VERBOSE=1;

my(@segs)=$origami->Segments();

    @segs
or  die gettext("No segment selected.")."\n";

    @segs != 2
and die gettext("Exactly two segments should be selected.")."\n";


    scalar(@{$segs[0]}) == 3
and scalar(@{$segs[1]}) == 3
or  die gettext("Each selected segment must be made of exactly 3 points.")."\n";

my($huzita)=Huzita6->new(@segs);
my(@solutions)=$huzita->Solutions();

    @solutions
or  die gettext("No fold found.")."\n";

    @solutions > 1
and warn sprintf(gettext("Warning : %d folds are possible!")."\n",scalar(@solutions));

for my $s (@solutions) {

  $origami->AddGuide($s->[0]);

      $origami->GetVar('proj') eq 'true'
  and do {
    $origami->AddPath($s->[1][0], $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));

    $origami->AddPath($s->[1][1], $origami->GetVar('pcolor'), $origami->GetVar('psize').$origami->GetVar('punit'));

  };
}

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();


