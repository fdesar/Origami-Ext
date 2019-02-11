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
my($type)='A';  # Angle N-Section

    (@segs != 1 or (scalar(@{$segs[0]}) != 2 and scalar(@{$segs[0]}) != 3))
and die gettext("ONE segment made of TWO or THREE points should be selected.")."\n";

    scalar(@{$segs[0]} == 2)
and $type='S';  # Segment N-Section

    OriMath::DistinctPoints(@{$segs[0]})
or  die gettext("All points should be distinct.")."\n";


my($nsec)=$origami->GetVar('nsec');

if ($type eq 'A') {
  my($seg)=[ [ @{$segs[0]}[1,0] ], [ @{$segs[0]}[1,2] ] ];
  my($po)=$segs[0][1];
  my($theta, $phi);
  my(@v);


  $v[0]=OriMath::Vec->new()->FromSeg(@{$seg->[0]})->Unit();
  $v[1]=OriMath::Vec->new()->FromSeg(@{$seg->[1]})->Unit();
  $theta=$v[0]->Theta($v[1]);

      $theta > pi
  and do {
    push(@v, shift(@v)); # swap vectors
    $theta=$v[0]->Theta($v[1]);
  };

  $theta/=$nsec;

  for (--$nsec;$nsec;--$nsec) {
    $v[1]=$v[1]->Rotate(-$theta);
    $origami->AddGuide($v[1]->ToSeg($po));
  }
}
else {
  my($seg)=$segs[0];
  my($vec)=OriMath::Vec->new()->FromSeg(@$seg);
  my($nsec)=$origami->GetVar('nsec');
  my($pvec)=$vec->Rotate(pi/2);
  my($p0)=$seg->[0];


  $vec=$vec->Mul(1/$nsec);

  for (my $i=1; $i<$nsec;++$i)  {
    my($p1)=$vec->ToPoint($p0);
    $origami->AddGuide($pvec->ToSeg($p1)); 
    $p0=$p1;
  }
}

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();
