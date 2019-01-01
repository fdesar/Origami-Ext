#!/usr/bin/perl

# To get a call stack trace if pb
use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

use Math::Trig qw/pi &rad2deg/;

my($origami)=Origami->new(@ARGV);

my(@segs)=$origami->Segments();

    (@segs != 1 or scalar(@{$segs[0]}) != 3)
and die gettext("ONE segment made of THREE points should be selected.")."\n";

    OriMath::DistinctPoints(@{$segs[0]})
or  die gettext("All points should be distinct.")."\n";

my($seg)=[ [ @{$segs[0]}[1,0] ], [ @{$segs[0]}[1,2] ] ];

my($po)=$segs[0][1];
my($theta, $phi);
my($nsec)=$origami->GetVar('nsec');
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

$origami->Apply();

