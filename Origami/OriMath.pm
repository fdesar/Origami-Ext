package OriMath;

use strict;
use warnings;
use Math::Trig;

# Compare if two floating point values are equal with a 7 decimals precision
sub Equals {
  my($a,$b)=@_;

  return sprintf("%.7f",$a) eq sprintf("%.7f",$b) ? 1 : 0;
}

sub Solve3 {
  my(@p)=@_;
  my($x0,$y0,$d);
  my($x1,$x2,$y1,$y2);

  my $Newton = sub {
    my($p, $t)=@_;
    my($t0)=$t+1;

    while (abs($t-$t0)>1e-10) {
      $t0=$t;
      $t-=($t**3+$p->[0]*$t**2+$p->[1]*$t+$p->[2])/(3*$t**2+2*$p->[0]*$t+$p->[1]);
    }

    return($t);
  };

      shift(@p) != 1.0
  and die "Solve3() : cannot solve equations with a!=1.\n";

  $x0=-$p[0]/3;
  $y0=$x0**3+$p[0]*$x0**2+$p[1]*$x0+$p[2];
  $d=$p[0]**2-3*$p[1];

      $d<0
  and return(&$Newton([@p], $x0));

  $d=sqrt($d);
  $x1=$x0-$d/3;
  $x2=$x0+$d/3;
  $y1=$x1**3+$p[0]*$x1**2+$p[1]*$x1+$p[2];
  $y2=$x2**3+$p[0]*$x2**2+$p[1]*$x2+$p[2];

      $y1<0
  and return(&$Newton([@p], $x2+1));

      $y2>0
  and return(&$Newton([@p],$x1-1));

  return(&$Newton([@p],$x1-1), &$Newton([@p],$x0), &$Newton([@p],$x2+1));
}

sub Solve2 {
    my($a,$b,$c)=@_;
    my($delta);

    $a == 0 and $b == 0 and return ();

    $a == 0 and return (-$c/$b);

    $delta=$b**2-4*$a*$c;

        $delta < 0
    and return ();

        $delta == 0
    and return -$b/(2*$a);

    return ((-$b+sqrt($delta))/(2*$a), (-$b-sqrt($delta))/(2*$a));
}

# Compute line equation from two points
# p1=[x,y] p2=[x,y] => (a, b, c)
# or [ [x, y], [x, y] ]
sub EqLine {
  my($p1, $p2) = @_==1 ? @{$_[0]} : @_;

  my($n)=sqrt(($p1->[0]-$p2->[0])**2 + ($p1->[1]-$p2->[1])**2);

     $n
  or die "The two lines segment points must be distinct\n";

  return [ ($p2->[1]-$p1->[1])/$n,
           ($p1->[0]-$p2->[0])/$n,
           ($p1->[1]*$p2->[0]-$p1->[0]*$p2->[1])/$n ];
}

sub PointsDist {
  my($p1, $p2)=@_;

  return(sqrt(($p2->[0]-$p1->[0])**2+($p2->[1]-$p1->[1])**2));
}

sub Perpendicular {
  my($f, $t)=@_;
 
  return [ $t->[1], -$t->[0], -$t->[1]*$f->[0]+$t->[0]*$f->[1] ];

}

# Compute p the intersection point of d1 and d2
# input  : [eq_d1], [eq_d2]
# output : [ x, y ]
sub LineIntersect {
  my($d1,$d2) =@_;
  my($p);

# Are d1 and d2 // ?
    IsZero($d2->[1]*$d1->[0]-$d1->[1]*$d2->[0])
and return undef;

  # d1 and d2 are secant 
  # Compute intersection point p of lines d1 and d2
  if($d1->[1] * $d2->[1] != 0) { # Neither lines are vertical
    $p->[0]=(-$d1->[2]*$d2->[1]+$d1->[1]*$d2->[2])/($d2->[1]*$d1->[0]-$d2->[0]*$d1->[1]);
    $p->[1]=(-$d1->[0]*$p->[0]-$d1->[2])/$d1->[1];
  }
  elsif ($d1->[1] == 0) { # Line d1 is vertical
    $p->[0] = -$d1->[2]/$d1->[0];
    $p->[1] = (-$d2->[2]-$d2->[0] * $p->[0])/$d2->[1];
  }
  else { # line d2 is vertical
    $p->[0] = -$d2->[2]/$d2->[0];
    $p->[1] = (-$d1->[2]-$d1->[0] * $p->[0])/$d1->[1];
  }

  return($p);
}

# Project a point p perpendicularly to line d on segment seg
# return undef if d and seg are // or f projection point pj is outside seg
# return segment [ p, pj ]
sub Projection {
  my($p)=shift;
  my($d)=shift;
  my($seg)=shift;
  my($dp,$ppj);

  $dp=OriMath::Perpendicular($p,$d);


      $ppj=OriMath::LineIntersect($dp, EqLine(@$seg)) # Line are // ?
  or  return undef;

      OriMath::PointInSegment($ppj, $seg)
  or  return(undef);

  # if p=ppj return seg rotated 90° crossing at point ppj 
  return    IsZero(OriMath::PointsDist($p,$ppj))
          ? OriMath::Vec->new()->FromSeg(@$seg)->Rotate(pi/2)->ToSeg($ppj)
          : [ $p, $ppj ];

}

# input p, seg : output 0 or 1 is p is in seg
# test if point p [x, y]   is inside segment Seg [ [x, y], [x, y] ]
sub PointInSegment {
  my($p)=shift;
  my($seg)=shift;

    return Equals(PointsDist($seg->[0], $p) + PointsDist($p, $seg->[1]), PointsDist($seg->[0], $seg->[1]));
}

sub MidPoint {
  my($p1,$p2)=@_;

  return( [ ( $p1->[0]+$p2->[0])/2 , ($p1->[1]+$p2->[1])/2 ] );
}

# Tells if a floating point is equal to 0 with a 7 decimals precision
sub IsZero {
  my($a)=@_;

  return sprintf("%.7f",abs($a)) eq sprintf("%.7f",0) ? 1 : 0;
}

sub DistinctPoints {
  my(@list)=@_;
  
  for (my $i=0; $i<@list; ++$i) {
    for(my $j=$i+1; $j<@list; ++$j) {
          sprintf("%.5f",$list[$i][0]) eq sprintf("%.5f",$list[$j][0])
      and sprintf("%.5f",$list[$i][1]) eq sprintf("%.5f",$list[$j][1])
      and return(0);
    }
  }
  return(1);
}

package OriMath::Vec;

use Math::Trig;

sub new {
  my($class)=shift;
  my($self)=[0,0];

      @_
  and @$self=(@_);

  bless($self,$class);
}

sub FromLine {
  my($self)=shift;
  my($line)=shift;

  $self->[0]=-$line->[1];
  $self->[1]=$line->[0];
  $self->Unit();

  return $self;
}

sub FromSeg {
  my($self)=shift;
  my($a, $b) = @_==1 ? @{$_[0]} : @_;

  $self->[0]= $b->[0]-$a->[0];
  $self->[1]= $b->[1]-$a->[1];

  return $self;
}

sub ToSeg {
  my($self)=shift;
  my($orig)=shift;
  
  return( [ $orig, [ $orig->[0]+$self->[0], $orig->[1]+$self->[1]] ] );
}

sub ToPoint {
  my($self)=shift;
  my($orig)=shift;
  
  return( [ $orig->[0]+$self->[0], $orig->[1]+$self->[1]] );
}

sub ToLine {
  my($self)=shift;
  my($orig)=shift;
  my($d);

  $self=$self->Unit();
  $d=[$self->[1], -$self->[0], 0]; 

  $d->[2]=-$d->[0]*$orig->[0]-$d->[1]*$orig->[1];

  return($d); 
}

sub Add {
  my($self)=shift;
  my($vec)=shift;

  bless([ $self->[0]+$vec->[0], $self->[1]+$vec->[1] ],ref($self));
}

sub Sub {
  my($self)=shift;
  my($vec)=shift;

  bless([ $self->[0]-$vec->[0], $self->[1]-$vec->[1] ], ref($self));
}

sub Mul {
  my($self)=shift;
  my($num)=shift;

  return bless([ $num*$self->[0], $num*$self->[1] ], ref($self));
}

sub Norm {
  my($self)=shift;

  return sqrt($self->[0]**2+$self->[1]**2);
}

sub Prod {
  my($self)=shift;
  my($vec)=shift;

  return $self->[0]*$vec->[0]+$self->[1]*$vec->[1];
}

sub Unit {
  my($self)=shift;

  return $self->Mul(1/$self->Norm);
}

#Determinant
sub Det {
  my($self)=shift;
  my($vec)=shift;
  
  return $self->[0]*$vec->[1]-$self->[1]*$vec->[0];
}

sub Cos {
  my($self)=shift;
  my($vec)=shift;

  return $self->Prod($vec)/($self->Norm()*$vec->Norm());
}

# Absolute angle between origin and vector from 0 to 2pi
# input none
sub Phi {
  my($self)=shift;
  my($vec)=OriMath::Vec->new(1,0);
  my($cos)=$vec->Cos($self);
  my($phi)=acos(sprintf("%.7f",$cos)); #acos($cos)

      $vec->Det($self) < 0
  and $phi=2*pi-$phi;

      OriMath::Equals($phi, 2*pi) #cas limite determinant=-0
  and $phi=0;

  return $phi;

}

# Absolute angle between two vectors from 0 to 2pi
sub Theta {
  my($self)=shift;
  my($vec)=shift;
  my($cos)=$self->Cos($vec);
  my($phi)=acos(sprintf("%.7f",$cos)); #acos($cos)

      $self->Det($vec) < 0
  and $phi=2*pi-$phi;

      OriMath::Equals($phi, 2*pi) #cas limite determinant=-0
  and $phi=0;

  return $phi;

}

sub Rotate {
  my($self)=shift;
  my($phi)=shift;

  bless([$self->[0]*cos($phi)-$self->[1]*sin($phi), $self->[0]*sin($phi)+$self->[1]*cos($phi)], ref($self));
}

sub X {
  my($self)=shift;
  return $self->[0];
}

sub Y {
  my($self)=shift;
  return $self->[1];
}

# For debugging purpose only : make a string from a vector
sub Print { 
  my($self)=shift;
  return sprintf("[%.3f,%.3f]",$self->[0], $self->[1]);
}


package OriMath::Parabola;

use Math::Trig;

sub new {
  my($class)=shift;
  my($self) = {
    f => shift,
    d => { seg => shift }
  };

  my $Chi =sub {
    my($eq)=shift;
    my($d)=$eq->[0]*$eq->[3]-$eq->[1]*$eq->[2];

    return [ ($eq->[3]**2/4-$eq->[1]**2*$eq->[4])/$d,
             (2*$eq->[0]*$eq->[1]*$eq->[4]-$eq->[2]*$eq->[3]/2)/$d,
             ($eq->[2]**2/4-$eq->[0]**2*$eq->[4])/$d,
             -$eq->[1],
             $eq->[0]
           ];
  };

  $self->{d}{eq} = OriMath::EqLine($self->{d}{seg});

  # Vérifier que le f n'est pas sur la d (ax+by+c=0)
      OriMath::IsZero(  $self->{d}{eq}[0]*$self->{f}[0]
                      + $self->{d}{eq}[1]*$self->{f}[1]
                      + $self->{d}{eq}[2])
  and die "Invalid segment : P cannot be on the line L it is projected to! (Should have been tested before)\n";

  $self->{eq} = [ $self->{d}{eq}[1],
                  -$self->{d}{eq}[0],
                  -2*($self->{f}[0]+$self->{d}{eq}[0]*$self->{d}{eq}[2]),
                  -2*($self->{f}[1]+$self->{d}{eq}[1]*$self->{d}{eq}[2]),
                  $self->{f}[0]**2+$self->{f}[1]**2-$self->{d}{eq}[2]**2
                ];

  $self->{chi}=&$Chi($self->{eq});

  bless($self, $class);
}

# Compute quadratic Bezier curve coordinates
# input : scale (scale * distance from focus to directrix)
# output : three quadratic Bezier curve coordinates + focus + origin
sub BezierQuad { 
  my($self)=shift; 
  my($scale)=shift; 
  my($pf)=$self->{f}; 
  my($dd)=$self->{d}{eq}; 
  my($po, $pa, $pb, $pc); 
  my($vo); 
  my($dp, $dt); 
 
  $scale or $scale=2; 
 
  # find line dp, perpendicular to directrix dd and crossing focus pf 
  $dp=OriMath::Perpendicular($pf, $dd); 
 
 
  # Get point PO 
  # po is at intersection of directrix dd and line dp 
  $po=OriMath::LineIntersect($dd, $dp); 
 
  # then vector vo 
  $vo=OriMath::Vec->new()->FromSeg($pf,$po); 
 
  #find point pc which is at vo*scale from focus pf  
  $pc=$vo->Mul($scale)->ToPoint($pf); 
 
  # find the two tangents crossing at pc 
  $dt=$self->Tangents($pc); 
 
 
  # get points pa and pb, the intersections between lines dt and the parabola 
  # (TangentPoint(d) method re-checks if line d really is a tangent to the parabola) 
  $pa=$self->TangentPoint($dt->[0]);
  $pb=$self->TangentPoint($dt->[1]);


  # return the three quadratic bezier curve points + focus and O
  return [$pa, $pc, $pb, $pf, $po];
}

# Find the (0..2) lines tangent to P crossing point p
sub Tangent2Point {
  my ($self)=shift;
  my($chi)=$self->{chi};
  my($p)=shift;
  my($r)=[];
  my(@t);

  # b=0 => tgs are V+H => two solutions : a=1, b=0, c=-x and a=0, b=-1 and c=y)
      OriMath::IsZero($chi->[0]-$p->[0]*$chi->[3]) # b=0 ?
  and return [ [ 1,  0, -$p->[0] ],   # a=1, b= 0, c=-x
               [ 0, -1,  $p->[1] ] ]; # a=0, b=-1, c=+y


  @t=OriMath::Solve2( $chi->[0]-$p->[0]*$chi->[3],
                      $chi->[1]-$p->[1]*$chi->[3]-$p->[0]*$chi->[4],
                      $chi->[2]-$p->[1]*$chi->[4]);

  for my $t (@t) {
    my($a)=sqrt($t**2/($t**2+1));
    my($b)=sqrt(1/($t**2+1));;
    my($d)=[ 0, 0, 0];

        $t < 0
    and $a = -$a;

    push(@$r, [$a, $b, -$a*$p->[0]-$b*$p->[1]]);
  }

  return $r;
}

# Find the (unique) line tangent // to vector v
sub Tangent2Vec {
  my ($self)=shift;
  my($chi)=$self->{chi};
  my($v)=shift;
  my($d)=[ $v->Y(), -$v->X(), 0];
  my($r)=[];

  # Verify there is a solution
      OriMath::IsZero($chi->[3]*$d->[0]+$chi->[4]*$d->[1])
  and return $r;

  $d->[2]=-($chi->[0]*$d->[0]**2+$chi->[1]*$d->[0]*$d->[1]+$chi->[2]*$d->[1]**2)/($chi->[3]*$d->[0]+$chi->[4]*$d->[1]);

  push(@$r, $d);

  return $r;
}

# Find the (0..3) common tangent lines with parabola p
sub Tangent2Parabola {
  my ($self)=shift;
  my($p)=shift;
  my($chi1)=$self->{chi};
  my($chi2)=$p->{chi};
  my($a)=$chi1->[0]*$chi2->[4]-$chi1->[4]*$chi2->[0]+$chi1->[1]*$chi2->[3]-$chi1->[3]*$chi2->[1]; # l2
  my($b)=$chi1->[1]*$chi2->[4]-$chi1->[4]*$chi2->[1]+$chi1->[2]*$chi2->[3]-$chi1->[3]*$chi2->[2]; # l1
  my($c)=$chi1->[2]*$chi2->[4]-$chi1->[4]*$chi2->[2]; # l0
  my($d)=$chi1->[0]*$chi2->[3]-$chi1->[3]*$chi2->[0]; # l3

  my($r)=[];

  my $Gamma = sub {
    my($a, $b) = @_;

        $chi1->[3]*$a+$chi1->[4]*$b == 0
    and $chi2->[3]*$a+$chi2->[4]*$b == 0
    and die sprintf("*** Complain fiercely : this should NEVER happen!!!!! ***\n%s\n%s\n",
                    $self->PrintInfo("P1"),
                    $self->PrintInfo("P2"));

    return    ($chi1->[3]*$a+$chi1->[4]*$b) == 0.0
            ? -($chi2->[0]*$a**2+$chi2->[1]*$a*$b+$chi2->[2]*$b**2)/($chi2->[3]*$a+$chi2->[4]*$b)
            : -($chi1->[0]*$a**2+$chi1->[1]*$a*$b+$chi1->[2]*$b**2)/($chi1->[3]*$a+$chi1->[4]*$b);
  };

      $d==0
  and do {
        $a == 0
    and return [ [1, 0, &$Gamma(1,0)] ];
    foreach my $s (OriMath::Solve2(1,$b/$a, $c/$a)) {
      push(@$r, [$s/sqrt($s**2+1), 1/sqrt($s**2+1), &$Gamma($s/sqrt($s**2+1), 1/sqrt($s**2+1))]);
    }
    return $r;
  };

  foreach my $s (OriMath::Solve3(1,$a/$d, $b/$d, $c/$d)) {
    my($a,$b)=($s/sqrt($s**2+1), 1/sqrt($s**2+1));
    # Special case where k3a*k4b=k'3a*k'4b : the directrix are // and this NOT in fact a solution
        OriMath::IsZero(($chi1->[3]*$a+$chi1->[4]*$b) * ($chi2->[3]*$a+$chi2->[4]*$b))
    and next;
    push(@$r, [ $a, $b, &$Gamma($a, $b) ]);
  }

  return $r;
}

# Compute tangent(s) to the parabola
# Input either a point, a vector or another parabola
# output is a ref array of lines (a,b,c) 
sub Tangents {
  my($self)=shift;
  my($obj)=shift;
  my($r)=[];

      ref($obj) eq 'ARRAY'
  and return $self->Tangent2Point($obj);

      ref($obj) eq 'OriMath::Vec'
  and return $self->Tangent2Vec($obj);

      ref($obj) eq 'OriMath::Parabola'
  and return $self->Tangent2Parabola($obj);

  die "Unknow object for parabola tangent !\n";

}

sub PrintInfo {
  my($self)=shift;
  my($label)=@_;

  return  sprintf("Parabola%s:\n", $label ? " [$label]" : '').
          sprintf("  focus = [%.7f, %.7f]\n",                   @{$self->{f}}[0,1]).
          sprintf("  Directrix = [ [%.7f, %.7f], [%.7f,%.7f] ]\n",     @{$self->{d}{seg}[0]},@{$self->{d}{seg}[1]}).
          sprintf("  Eq_Directrix = [ %.7f, %.7f, %.7f ]\n",            @{$self->{d}{eq}}).
          sprintf("  Eq_Parabola = [ %.7f, %.7f, %.7f, %7f, %.7f ]\n", @{$self->{eq}}).
          sprintf("  Chi = [ %.7f, %.7f, %.7f, %7f, %.7f ]\n", @{$self->{chi}}).
          sprintf("----------------\n");
}

# d beeing a tangent to P, find p, the point of line d element of P
# Input: d a line equation [a, b, c]
# Output: a point [x, y]
# die if d is not tangent to P
sub TangentPoint {
  my($self)=shift;
  my($d)=shift;
  my($eq)=$self->{eq};
  my($chi)=$self->{chi};
  my($x, $y);

  # Check that $d really is a tangent of P:
  # we must have k0a^2+k1ab+k2b^2+k3ac+k4bc=0
      OriMath::IsZero(
          $chi->[0]*$d->[0]**2
        + $chi->[1]*$d->[0]*$d->[1]
        + $chi->[2]*$d->[1]**2
        + $chi->[3]*$d->[0]*$d->[2]
        + $chi->[4]*$d->[1]*$d->[2])
  or  die "P->TangentPoint(p): d is not tangent to P.\n";

 $x =   (($eq->[1]*$d->[2]) / ($eq->[0]*$d->[1]-$eq->[1]*$d->[0]))
       - (  ($d->[1]*($eq->[2]*$d->[1]-$eq->[3]*$d->[0])
          / (2*($eq->[0]*$d->[1]-$eq->[1]*$d->[0])**2)));

  $y =   ((-$eq->[0]*$d->[2]) / ($eq->[0]*$d->[1]-$eq->[1]*$d->[0]))
       + (  ($d->[0]*($eq->[2]*$d->[1]-$eq->[3]*$d->[0])
          / (2*($eq->[0]*$d->[1]-$eq->[1]*$d->[0])**2)));

  return [$x, $y];

}

1;
