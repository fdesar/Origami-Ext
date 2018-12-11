use strict;
use warnings;

package Huzita5;

use Origami;

sub new {
  my($class)=shift;
  
  my($self)= {
          p1 =>  shift,
          p2 =>  shift,
          d  =>  shift
      };

  bless($self,$class);
}

sub Solution {
  my($self)=shift;
  my($p1)=$self->{p1};
  my($p2)=$self->{p2};
  my($r)= OriMath::PointsDist($p1, $p2);
  my(@p);

  my $Translate = sub {
    my($sign)=shift;
    my($t)=shift;
    my($d)=shift;

      for (@$d) {
        $_->[0]+=$sign*$t->[0];
        $_->[1]+=$sign*$t->[1];
      }
      return $d;
  };
  
  my $Project = sub {
    my($p)=$self->{p1};
    my($d_coord);
    my(@d);
    my(@sol);

    my $Translate = sub {
      my($sign)=shift;
      my($t)=shift;
      my($d)=shift;

        for (@$d) {
          $_->[0]+=$sign*$t->[0];
          $_->[1]+=$sign*$t->[1];
        }
        return $d;
    };

    # Make REAL scalar copy of the values as they will be translated !
    $d_coord->[0][0]=$self->{d}[0][0];
    $d_coord->[0][1]=$self->{d}[0][1];
    $d_coord->[1][0]=$self->{d}[1][0];
    $d_coord->[1][1]=$self->{d}[1][1];

  
    $d_coord=&$Translate(-1,$p, $d_coord);

    @d=OriMath::EqLine($d_coord->[0], $d_coord->[1]);

    if($d[1] != 0) { # Cas général
      my($a)=-$d[0]/$d[1];
      my($b)=-$d[2]/$d[1];

      for (OriMath::Solve2(1+$a**2, 2*$a*$b, $b**2-$r**2)) {
        push(@sol,[ $_, $a*$_+$b]);
      }
    }
    else { # Cas ou la directrice est une verticale !!!LES TROIS CAS SONT TESTÉS!!!
      my($x)=-$d[2]/$d[0];
      my($delta) = $r**2-$x**2;

    BLK: {
            $delta < 0
        and last BLK;

            $delta == 0
        and do {
          push(@sol, [ $x, 0 ]);
          last BLK;
        };

        push(@sol,[ $x, sqrt($delta) ]);
        push(@sol,[ $x, -sqrt($delta) ]);
      }
    }
    
    return @{&$Translate(1,$p,[@sol])};

  };

  for my $pj (&$Project()) {
    my($mp)=OriMath::MidPoint($p2, $pj);

        OriMath::PointInSegment($pj, $self->{d})
    and push(@p,[[ $p1, $mp ], [ $p2, $pj ]]);
  }

  return @p;

}

1;
