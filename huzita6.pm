use strict;
use warnings;

package Huzita6;

use Origami;

use Exporter 'import';
our @EXPORT=qw($VERBOSE);

our $VERBOSE;

sub Parabola {
  my($parabola) = {
    _foyer => shift,
    _directrice => { coord => [ shift, shift ] }
  };

  my $EqParabole = sub {
    my($f, $d) = @_;

    return ( $d->[1],
             -$d->[0],
             -2*($f->[0]+$d->[0]*$d->[2]),
             -2*($f->[1]+$d->[1]*$d->[2]),
             $f->[0]**2+$f->[1]**2-$d->[2]**2
          );

  };

  my $EqTangente = sub {
    my($p) = shift;
    my($d)=$p->[0]*$p->[3]-$p->[1]*$p->[2];

    return ( ($p->[3]**2/4-$p->[1]**2*$p->[4])/$d,
             (2*$p->[0]*$p->[1]*$p->[4]-$p->[2]*$p->[3]/2)/$d,
             ($p->[2]**2/4-$p->[0]**2*$p->[4])/$d,
             -$p->[1],
             $p->[0]
           )
  };

      $VERBOSE
  and do {
    warn "-------------------\n";
    warn sprintf("Segment 1: [ [%.7f, %.7f], [%.7f, %.7f], [%.7f, %.7f]]\n",
                  @{$parabola->{_foyer}},
                  @{$parabola->{_directrice}{coord}[0]},
                  @{$parabola->{_directrice}{coord}[1]});
    warn "-------------------\n";
  };

  $parabola->{_directrice}{equation} =  [ OriMath::EqLine(@{$parabola->{_directrice}{coord}}) ];


  # Vérifier que le foyer n'est pas sur la directrice (ax+by+c=0)
      abs(  $parabola->{_directrice}{equation}[0]*$parabola->{_foyer}[0]
          + $parabola->{_directrice}{equation}[1]*$parabola->{_foyer}[1]
          + $parabola->{_directrice}{equation}[2]) < 0.00000001
  and die gettext("Invalid segment : P cannot be on the line D it is projected to!")."\n";

  $parabola->{_equation} =  [ &$EqParabole($parabola->{_foyer}, $parabola->{_directrice}{equation}) ];
  $parabola->{_tangente} =  [ &$EqTangente($parabola->{_equation}) ];

      $VERBOSE
  and do {
    warn("Parabola :\n");
    warn(sprintf("  focus         = [%.7f, %.7f]\n",                    @{$parabola->{_foyer}}[0,1]));
    warn(sprintf("  Directrix     = [[%.7f, %.7f],[%.7f,%.7f]]\n",      @{$parabola->{_directrice}{coord}[0]}[0,1],
                                                                        @{$parabola->{_directrice}{coord}[1]}[0,1]));
    warn(sprintf("  Eq_Directrix  = [ %.7f, %.7f, %.7f]\n",             @{$parabola->{_directrice}{equation}}));
    warn(sprintf("  Eq_Parabola   = [ %.7f, %.7f, %.7f, %7f, %.7f]\n",  @{$parabola->{_equation}}));
    warn(sprintf("  Eq_Tangent    = [ %.7f, %.7f, %.7f, %7f, %.7f]\n",  @{$parabola->{_tangente}}));
    warn("----------------\n");
  };

  return($parabola);
}


sub Solutions {
  my($self)=shift;
  my(@solutions);

  # eq_tg, eq_p1, eq_p2 => ([x,y], [x,y]
  my $Segment = sub {
    my(@t)=@{$_[0]};
    my(@p1)=@{$_[1]};
    my(@p2)=@{$_[2]};

    my $Point = sub {
      my(@p) = @_;

      return [    (($p[1]*$t[2]) / ($p[0]*$t[1]-$p[1]*$t[0]))
              - (  ($t[1]*($p[2]*$t[1]-$p[3]*$t[0])
                  / (2*($p[0]*$t[1]-$p[1]*$t[0])**2))),

                  ((-$p[0]*$t[2]) / ($p[0]*$t[1]-$p[1]*$t[0]))
              + (  ($t[0]*($p[2]*$t[1]-$p[3]*$t[0])
                  / (2*($p[0]*$t[1]-$p[1]*$t[0])**2)))] ;

    };

    return [ &$Point(@p1), &$Point(@p2) ];
  };


  for my $t (@{$self->{tangents}}) {
    my(@foyer)= ($self->{p1}{_foyer}, $self->{p2}{_foyer});
    my(@dir)= ($self->{p1}{_directrice}{coord}, $self->{p2}{_directrice}{coord});
    my(@proj);
    my($seg);

        $VERBOSE
    and do {
      warn "--------------------------\n";
      warn(sprintf("Tangent found : [%.7f, %.7f, %.7f]\n",@$t));
      warn "--------------------------\n";
    };

    # Keep foldable tangents only and get their projection points

    # Get projections
    $proj[0]=OriMath::OrthProject($foyer[0], $t, $dir[0]);
    $proj[1]=OriMath::OrthProject($foyer[1], $t, $dir[1]);

    # Check if projections are on disrectrix segment
        OriMath::PointInSegment($proj[0],$dir[0])
    and OriMath::PointInSegment($proj[1],$dir[1])
    or  next;

    $seg=&$Segment($t, $self->{p1}{_equation}, $self->{p2}{_equation});

        $VERBOSE
    and do {
      warn "--------------------------\n";
      warn(sprintf("Foldable tangent: [%.7f, %.7f], [%.7f, %.7f]\n",@{$seg->[0]},@{$seg->[1]}));
      warn sprintf("Projection 1  : [%.7f, %.7f] to [%.7f, %.7f]\n", @{$foyer[0]}, @{$proj[0]}); 
      warn sprintf("Projection 2  : [%.7f, %.7f] to [%.7f, %.7f]\n", @{$foyer[1]}, @{$proj[1]}); 
      warn "--------------------------\n";
    };

    push(@solutions, [ $seg, [ [$foyer[0], $proj[0] ], [ $foyer[1], $proj[1] ] ]  ]);
  }

  return(@solutions);
}

sub new {
  my($class)=shift;
  my($self);
  my(@seg)=@_;
  my($p1) = Parabola(@{$seg[0]});
  my($p2) = Parabola(@{$seg[1]});
  my($tangents);
  my(@tan);

  my $CommonTangents = sub {
    my(@t1)=@{$_[0]};
    my(@t2)=@{$_[1]};
    my(@seg);
    my(@r)=();

    my($a)=($t1[0]*$t2[4]-$t1[4]*$t2[0]+$t1[1]*$t2[3]-$t1[3]*$t2[1]);
    my($b)=($t1[1]*$t2[4]-$t1[4]*$t2[1]+$t1[2]*$t2[3]-$t1[3]*$t2[2]);
    my($c)=($t1[2]*$t2[4]-$t1[4]*$t2[2]);
    my($d)=$t1[0]*$t2[3]-$t1[3]*$t2[0];

    my $Gamma = sub {
      my($alpha, $beta) = @_;

          ($t1[3]*$alpha+$t1[4]*$beta) == 0.0
      and ($t2[3]*$alpha+$t2[4]*$beta) == 0.0
      and die "This should never happen!!!!!\n";

      return    ($t1[3]*$alpha+$t1[4]*$beta) == 0.0
              ? -($t2[0]*$alpha**2+$t2[1]*$alpha*$beta+$t2[2]*$beta**2)/($t2[3]*$alpha+$t2[4]*$beta)
              : -($t1[0]*$alpha**2+$t1[1]*$alpha*$beta+$t1[2]*$beta**2)/($t1[3]*$alpha+$t1[4]*$beta);
    };

    if($d == 0.0) { # Cas particuliers où d=0
      if($a == 0.0) { # Cas particulier n°1 = d=0 et a=0 : une tangente horizontale
        push(@r, [0, 1, &$Gamma(0,1)]);
      }
      else { # Cas particulier où d=0 et a!=0 : une seule tangente verticale 
        if ($c == 0.0) { # Cas particulier d=0, a!=0 et c=0
          push(@r, [1, 0, &$Gamma(1,0)]);
        }
        else { # Cas particulier d=0, a!=0 et c!=0 : 0 à deux tangentes
          foreach my $s (OriMath::Solve2(1,$b/$a, $c/$a)) {
            push(@r, [$s, 1, &$Gamma($s, 1)]);
          }
        }
      }
    } # Fin des cas particuliers : 0 à trois tangentes
    else { # Cas général d !=0 : résoudre equation du 3e degré
      foreach my $s (OriMath::Solve3(1,$a/$d, $b/$d, $c/$d)) {
        push(@r, [$s/sqrt($s**2+1), 1/sqrt($s**2+1), &$Gamma($s/sqrt($s**2+1), 1/sqrt($s**2+1))]);
      }
    }

    return [ @r ];
  };

  $tangents= &$CommonTangents($p1->{_tangente}, $p2->{_tangente});

  $self={ p1 => $p1, p2 => $p2, tangents => $tangents };
  bless($self, $class);
  return $self
}

1;
