#!/usr/bin/perl


use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

use Math::Trig;

sub Sort {
  my(@vlist)= @_;
  my(@r);

  my(%cache) = map { $_->Phi() => $_ } @vlist;

  @r = map { $cache{$_} } sort { $a <=> $b } keys(%cache);

  return @r;
}

my($origami)=Origami->new(@ARGV);
my(@segs)=$origami->Segments();
my(@sol)=();
my($solinx);

    (@segs != 1 or scalar(@{$segs[0]}) != 5)
and die gettext("ONE segment made of FIVE points should be selected.")."\n";

my($o, $a, $b, $c, $q)=@{$segs[0]};

    OriMath::DistinctPoints($o,$a,$b,$c,$q)
or  die gettext("All points should be distinct.")."\n";

my($va) = OriMath::Vec->new()->FromSeg($o,$a);
my($vb) = OriMath::Vec->new()->FromSeg($o,$b);
my($vc) = OriMath::Vec->new()->FromSeg($o,$c);
my($vq) = OriMath::Vec->new()->FromSeg($o,$q);

($va,$vb,$vc)=Sort($va, $vb, $vc);

for (0..2) { # 3 possible solutions a priori
  my(@theta);
  my($tmp);

  $theta[0]=$va->Theta($vb);
  $theta[1]=$vb->Theta($vc);
  $theta[2]=pi-$theta[0];

      $theta[0] <= pi
  and $theta[1] <= pi
  and do {
    push(@sol,$vc->Rotate($theta[2])->ToSeg($o));

# Solution in requested quadrant ?
#    (VA > VC ET VQ > VC ET VQ < VA)
# OU (VA < VC ET ((VQ > VC ET VQ > VA) OU (VQ < VC ET VQ < VA)) 
#   
        (   ($va->Phi() > $vc->Phi() and $vq->Phi() > $vc->Phi() and $vq->Phi() < $va->Phi())
        or ($va->Phi() < $vc->Phi() and (($vq->Phi() > $vc->Phi() and $vq->Phi() > $va->Phi()) or ($va->Phi() < $vc->Phi() and $vq->Phi() < $va->Phi())))) 
    and $solinx= $_;
  };

  $tmp=$va;
  $va=$vb;
  $vb=$vc;
  $vc=$tmp;
} 

    not defined($solinx)
and warn gettext("No solution for the requested quadrant : the unique solution will be drawn.")."\n";

  @sol == 1
? $origami->AddGuide($sol[0])
: $origami->AddGuide($sol[$solinx]);

    $origami->GetVar('clean') eq 'true'
and $origami->RemoveSelection();

$origami->Apply();
