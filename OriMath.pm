package OriMath;

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
sub EqLine {
  my($p1, $p2) = @_;

  my($n)=sqrt(($p1->[0]-$p2->[0])**2 + ($p1->[1]-$p2->[1])**2);

     $n
  or die "The two line segment points must be distinct\n";

  return ( ($p2->[1]-$p1->[1])/$n,
           ($p1->[0]-$p2->[0])/$n,
           ($p1->[1]*$p2->[0]-$p1->[0]*$p2->[1])/$n );
}

sub PointsDist {
  my($p1, $p2)=@_;

  return(sqrt(($p2->[0]-$p1->[0])**2+($p2->[1]-$p1->[1])**2));
}

sub Perpendicular {
  my($f, $t)=@_;
 
  return($t->[1], -$t->[0], -$t->[1]*$f->[0]+$t->[0]*$f->[1]);

}

# Project point F [x,y) perpendicular to line T_equ [a,b,c] to onto line D_coord [ [x, y], [x, y] ].
#Return point [x, y]
sub OrthProject {
  my($f, $t, $d_coord) = @_;
  my(@d)= EqLine(@$d_coord);
  my(@pl) = ( 0.0, 0.0, 0.0 );
  my($p) = [ 0.0, 0.0 ];


  # Check if T and D are //
  # TODO
  # return(undef);

  # Compute pl, the perlpendicular of line t crossing point f
  @pl= Perpendicular($f, $t);

  # Compute intersection point p of lines pl and d
  if($pl[1] * $d[1] != 0) { # Neither lines are vertical
    $p->[0]=(-$pl[2]*$d[1]+$pl[1]*$d[2])/($d[1]*$pl[0]-$d[0]*$pl[1]);
    $p->[1]=(-$pl[0]*$p->[0]-$pl[2])/$pl[1];
  }
  elsif ($pl[1] == 0) { # Line pl is vertical
    $p->[0] = -$pl[2]/$pl[0];
    $p->[1] = (-$d[2]-$d[0] * $p->[0])/$d[1];
  }
  else { # line d is vertical
    $p->[0] = -$d[2]/$d[0];
    $p->[1] = (-$pl[2]-$pl[0] * $p->[0])/$pl[1];
  }

  return($p);
}

# input p, seg : output 0 or 1 is p is in seg
# test if point p [x, y]   is inside segment Seg [ [x, y], [x, y] ]
sub PointInSegment {
  my($p)=shift;
  my($seg)=shift;

         return     sprintf("%.5f",PointsDist($seg->[0], $p) + PointsDist($p, $seg->[1]))
                eq  sprintf("%.5f",PointsDist($seg->[0], $seg->[1]))
}

sub MidPoint {
  my($p1,$p2)=@_;

  return( [ ( $p1->[0]+$p2->[0])/2 , ($p1->[1]+$p2->[1])/2 ] );
}

1;
