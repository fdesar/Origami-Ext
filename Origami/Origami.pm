package Origami;

# To get a call stack trace if pb
#use Carp;
#$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));
use lib dirname(abs_path(__FILE__)).'/perllib';


use Getopt::Long qw/GetOptionsFromArray/;

use XML::LibXML;
use XML::LibXML::XPathContext;

use bignum;

use OriMath;

#-------------------------------------------
# Localization
#-------------------------------------------
# export gettext to be widely available
use Exporter 'import';
@EXPORT=qw(gettext);

# Define gettext() sub
    eval { # Try Locale::gettext
      require Locale::gettext;
      Locale::gettext::textdomain('Origami');
      Locale::gettext::bindtextdomain('Origami', dirname(abs_path(__FILE__))."/locale");
      eval 'sub gettext { return Locale::gettext::gettext(shift) }';
      return 1;
    }
or  eval { # then try Locale::gettext_basic (pure Perl) module 
      require Locale::gettext_basic;
      Locale::gettext_basic::textdomain('Origami');
      Locale::gettext_basic::bindtextdomain('Origami', dirname(abs_path(__FILE__))."/locale");
      eval 'sub gettext { return Locale::gettext_basic::gettext(shift) }';
      return 1;
    }
or  eval 'sub gettext { return shift }'; # then if no lib found, default to do nothing

#-------------------------------------------

# Private variables

my %_NS=( 'svg'      => 'http://www.w3.org/2000/svg',
          'sodipodi' => 'http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd',
          'cc'       => 'http://creativecommons.org/ns#',
          'ccOLD'    => 'http://web.resource.org/cc/',
          'dc'       => 'http://purl.org/dc/elements/1.1/',
          'rdf'      => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
          'inkscape' => 'http://www.inkscape.org/namespaces/inkscape',
          'xlink'    => 'http://www.w3.org/1999/xlink',
          'xml'      => 'http://www.w3.org/XML/1998/namespace'
        );

my %_Units = (
  'px' => 1.0,
  'pt' => 4.0/3.0,
  'pc' => 16.0,
  'in' => 96.0,
  'mm' => 96.0/25.4,
  'cm' => 96.0/2.54
);

# Common RE patterns
my($re_uinteger)='\d+';
my($re_integer)="[+-]?$re_uinteger";
my($re_num)="$re_integer(?:.$re_uinteger+)?(?:[Ee]$re_integer)?";



# Private methods : all prefixed by _

sub _Dim2Pixel {
  my($self)=shift;
  my($value) = @_;

  my($unit);

      $value =~ /^\s*($re_num)\s*(..)?\s*/
  or  die "Dim2Pixel('$value') : invalid size.\n";

     defined($2)
  and exists($_Units{$2})
  and return($1*$_Units{$2});

  return($1); # Assume px

}

# Generate a prefixed pseudo-unique ID
# input : a prefix string
{
  my $id=join('', map{int(rand(10))}1..6);

  sub _UniqueId {
    my($self,$pfx)=@_;
    $id+=2;
    return($pfx.$id);
  }

}

# Parse a path for straight unique segment : return [ [x, y], ... ]
# input : a SVG path string
sub _ParseSVGPath {
  my($self)=shift;
  my($path)=@_;

  # RE patterns tous les wsp inutiles doivent avoir été supprimés
  my($re_cmd)="[ASCLHVZMasclhvzm]"; # Les courbes et arcs sont ignorées
  my($re_notcmd)="[^ASCLHVZMasclhvzm]"; # Les courbes et arcs sont ignorées
  my($re_numpair)="$re_num,$re_num";
  my($re_moveto)="[Mm]$re_numpair(:?\\s$re_numpair)*";
  my($re_lineto)="[Ll]?$re_numpair(?:\\s$re_numpair)*";
  my($re_hline)="[Hh]$re_num(?:\\s$re_num)*";
  my($re_vline)="[Vv]$re_num(?:\\s$re_num)*";
  my($re_curveto)="[Cc]$re_numpair\\s$re_numpair\\s$re_numpair(?:\\s$re_numpair\\s$re_numpair\\s$re_numpair)*";
  my($re_scurveto)="[Ss]$re_numpair\\s$re_numpair(?:\\s$re_numpair\\s$re_numpair)*";
  my($re_arcto)="[Aa]$re_numpair\\s(:?$re_num\\s){3}$re_numpair(?:\\s(:?$re_numpair\\s(:?$re_num\\s){3}$re_numpair))*";
  my($re_closing) = "[Zz]";
  my($re_path)="^$re_moveto(?:$re_moveto|$re_lineto|$re_scurveto|$re_curveto|$re_arcto|$re_hline|$re_vline)*$re_closing?\$";
  # fin des RE

  my(@path);
  my($cur_x, $cur_y)=(0.0, 0.0);
  my(@points)=();

  my $MoveTo = sub {
    my($cmd,@args)=@_;

    for (@args) {
      my($x, $y)= map { $_+0.0 } split(',',$_);
      push(@points, [ $x+0.0, $y+0.0]);
        $cmd eq 'm'
      and do {
        $points[-1][0]+=$cur_x;
        $points[-1][1]+=$cur_y;
      };
      $cur_x=$points[-1][0];
      $cur_y=$points[-1][1];
    }
    
  };

  my $LineTo = sub {
    my($cmd,@args)=@_;

    # un lineto est comme un moveto...
    &$MoveTo($cmd eq 'L' ? 'M' : 'm', @args);
  };

  my $ArcTo = sub {
    my($cmd,@args)=@_;
    my(@newargs);

    #Get from coor, skip arg, flag1 & flag2 and get the to coord
    while (@args) {
      push(@newargs, shift(@args));
      shift(@args);
      shift(@args);
      shift(@args);
      push(@newargs, shift(@args));
    }

    # then a CurveTo is like a MoveTo
    &$MoveTo($cmd eq 'C' ? 'M' : 'm', @newargs);
    
  };

  my $CurveTo = sub {
    my($cmd,@args)=@_;
    my(@newargs);

    #skip the two control points and get the coord
    while (@args) {
      shift(@args);
      shift(@args);
      push(@newargs, shift(@args));
    }

    # then a CurveTo is like a MoveTo
    &$MoveTo($cmd eq 'C' ? 'M' : 'm', @newargs);
    
  };

  my $SmoothCurveTo = sub {
    my($cmd,@args)=@_;
    my(@newargs);

    #skip the single control points and get the coord
    while (@args) {
      shift(@args);
      push(@newargs, shift(@args));
    }

    # then a CurveTo is like a MoveTo
    &$MoveTo($cmd eq 'S' ? 'M' : 'm', @newargs);
    
  };

  my $VLineTo = sub {
    my($cmd,@args)=@_;

    for (@args) {
      my($x, $y)= ($cur_x,$_+0.0);

      push(@points, [ $x+0.0, $y+0.0]);
        $cmd eq 'v'
      and $points[-1][1]+=$cur_y;
      $cur_x=$points[-1][0];
      $cur_y=$points[-1][1];
    }
  };

  my $HLineTo = sub {
    my($cmd,@args)=@_;

    for (@args) {
      my($x, $y)= ($_+0.0,$cur_y);
      push(@points, [ $x+0.0, $y+0.0]);
        $cmd eq 'h'
      and $points[-1][0]+=$cur_x;
      $cur_x=$points[-1][0];
      $cur_y=$points[-1][1];
    }
  };

  my $Close = sub {
    my($cmd,@args)=@_;
  };


  my $CleanUp = sub {
    $path =~ s/\s+/ /g; # wsp multiples => wsp
    $path =~ s/\s*,\s*/,/g; # supprimer les wsp autour des ','
    $path =~ s/\s*($re_cmd)\s*/$1/ig; # supprimer les wsp autour des commandes 
  };

  &$CleanUp();

     $path =~ /$re_path/
  or die "Invalid straight lines segment path : '@_'.\n";

  # Constituer la liste des commandes+arguments qui ont déjà été validés
  while($path=~s/^($re_cmd$re_notcmd*)//i) {
    push(@path, $1);
  }

      substr($path[0],0,1) !~ /[Mm]/
  and die "Invalid SVG path '@_' : should beging with a moveto command.\n";

  for (@path) {
    my($cmd)=substr($_,0,1);
    my(@args)=split(' ',substr($_,1));


    SWITCH:
    for($cmd) {
      if(/[Mm]/)  { &$MoveTo($cmd, @args); last SWITCH }
      if(/[Ll]/)  { &$LineTo($cmd, @args); last SWITCH }
      if(/[Cc]/)  { &$CurveTo($cmd, @args); last SWITCH }
      if(/[Ss]/)  { &$SmoothCurveTo($cmd, @args); last SWITCH }
      if(/[Vv]/)  { &$VLineTo($cmd, @args); last SWITCH }
      if(/[Hh]/)  { &$HLineTo($cmd, @args); last SWITCH }
      if(/[Aa]/)  { &$ArcTo($cmd, @args); last SWITCH }
      if(/[Zz]/)  { &$Close($cmd, @args); last SWITCH }
      die "This shouldn't happen!!!";
    }

  }
  return(@points);
}

# End of private methods


# Public Methods

sub _AddElement {
  my($self)=shift;
  my($node)=shift;
  my($object)=shift;

  $node->appendChild($object);
}

# Create Path element
# input : ([ [x, y], ... ], color, stroke-width) output: node
sub _NewPath {
  my($self)=shift;
  my($points)=shift;
  my($color)=shift;
  my($stroke)=shift;
  my($node)=XML::LibXML::Element->new("path");
  my($id)=$self->_UniqueId("path");
  my($svg_path)="M ";
  my(%style) =  ( 'opacity' => "1",
                  'vector-effect' => "none",
                  'fill' => "none",
                  'fill-opacity' => "1",
                  'fill-rule' => "evenodd",
                  'stroke-linecap' => "round",
                  'stroke-linejoin' => "round",
                  'stroke-miterlimit' => "4",
                  'stroke-dasharray' => "none",
                  'stroke-dashoffset' => "0",
                  'paint-order' => "normal");
  my($style)="";

  @$points > 1 or die "_NewPath() : invalid number of points.\n";

  # Compute and add style element

  # Compute and add stroke-width style attribute
  $stroke=$self->_Dim2Pixel($stroke) * ($self->{document}{svg}{viewbox}[3]/$self->{document}{svg}{height});

  $style{'stroke-width'}=sprintf("%.7f",$stroke);

  # Compute stroke (color and alpha) style attribute
  $style{'stroke'}="#".substr(sprintf("%8.8x",$color),-8,6);
  $style{'stroke-opacity'}=sprintf("%.2f",($color&0xff)/255);

  for my $k (keys(%style)) {
    $style.="$k:$style{$k};";
  }
  chop($style);

  # Compute and add d (path) element
  #Build SVG path
  for (@$points) {
    $svg_path .= sprintf("%.5f,%.5f ",$_->[0],$_->[1]);
  }
  chop($svg_path); #remove trailing whitespace

  # Add attributes
  $node->setAttribute("inkscape:connector-curvature","0");
  $node->setAttribute("id",$id);
  $node->setAttribute("d",$svg_path);
  $node->setAttribute("style",$style);

  return $node;
}

# Create Quadrtic Bezier Path element if more points are given append
# a straight line subpath with them
# input : ([ [x, y], [x, y], [x, y] ]
# output: node
sub _NewQBPath {
  my($self)=shift;
  my($points)=shift;
  my($color)=65408; # Blue, alpha=50
  my($stroke)="1px";
  my($node)=XML::LibXML::Element->new("path");
  my($id)=$self->_UniqueId("path");
  my($svg_path)="M ";
  my(%style) =  ( 'opacity' => "1",
                  'vector-effect' => "none",
                  'fill' => "none",
                  'fill-opacity' => "1",
                  'fill-rule' => "evenodd",
                  'stroke-linecap' => "round",
                  'stroke-linejoin' => "round",
                  'stroke-miterlimit' => "4",
                  'stroke-dasharray' => "none",
                  'stroke-dashoffset' => "0",
                  'paint-order' => "normal");
  my($style)="";

      @$points != 3
  and @$points != 5
  and die "_NewQBPath() : invalid number of points.\n";

  # Compute and add style element

  # Compute and add stroke-width style attribute
  $stroke=$self->_Dim2Pixel($stroke) * ($self->{document}{svg}{viewbox}[3]/$self->{document}{svg}{height});

  $style{'stroke-width'}=sprintf("%.7f",$stroke);

  # Compute stroke (color and alpha) style attribute
  $style{'stroke'}="#".substr(sprintf("%8.8x",$color),-8,6);
  $style{'stroke-opacity'}=sprintf("%.2f",($color&0xff)/255);

  for my $k (keys(%style)) {
    $style.="$k:$style{$k};";
  }
  chop($style);

  # Compute and add d (path) element
  #Build SVG path
  $svg_path .= sprintf("%.5f,%.5f Q %5f,%5f %5f,%5f",@{$points->[0]},@{$points->[1]},@{$points->[2]});

      @$points >3
  and $svg_path .= sprintf(" M %.5f,%.5f %5f,%5f",@{$points->[3]},@{$points->[4]});

  # Add attributes
  $node->setAttribute("inkscape:connector-curvature","0");
  $node->setAttribute("id",$id);
  $node->setAttribute("d",$svg_path);
  $node->setAttribute("style",$style);

  return $node;
}


sub _NewGuide {
  my($self)=shift;
  my($seg)=shift;
  my($offset)=$self->{document}{svg}{height};
  my($line_eq)= OriMath::EqLine([ $seg->[0][0], -$seg->[0][1] ], [ $seg->[1][0], -$seg->[1][1] ]);
  #my($angle)=atan2($line_eq->[0], -$line_eq->[1]);
  my($angle)=atan2(sprintf("%.7f",$line_eq->[0]), sprintf("%.7f",-$line_eq->[1]));
  my($node)=XML::LibXML::Element->new("sodipodi:guide");
  my($position,$orientation);

  # Offset correction if current-layer has been translated
  $offset-=$self->{document}{current_layer}{transform};
  # Offset correction if scale has been modified
  $offset *= $self->{document}{svg}{viewbox}[3]/$self->{document}{svg}{height};

  $position = [ $seg->[0][0], -$seg->[0][1]+$offset ];
  $orientation=[ -sin($angle), cos($angle) ];

  $node->setAttribute("id",$self->_UniqueId("guide"));
  $node->setAttribute("position",sprintf("%.7f,%.7f", @$position));
  $node->setAttribute("orientation",sprintf("%.7f,%.7f",@$orientation));
  $node->setAttribute("inkscape:locked","false");

  return $node;
}

#----------------

sub Segments {
  my($self)=shift;
  my(@segs) = ();


  for my $path (@{$self->{select}{path}}) {
    my($seg, $segment);

    $seg = [ $self->_ParseSVGPath($path->{d}) ];

    push(@segs, $seg);
  }

  return (@segs);
}

sub AddPath {
  my($self)=shift;
  $self->_AddElement($self->{document}{current_layer}{node}, $self->_NewPath(@_));
}

sub AddQBPath {
  my($self)=shift;
  $self->_AddElement($self->{document}{current_layer}{node}, $self->_NewQBPath(@_));
}

sub AddGuide {
  my($self)=shift;
  $self->_AddElement($self->{document}{namedview}, $self->_NewGuide(@_));
}

# Get variable given by Inkscape
# input : <variable name> output: <value>
sub GetVar {
  my($self)=shift;
  my($key)=shift;

      exists $self->{args}{$key}
  and return $self->{args}{$key};

  return undef;
}

sub RemoveSelection {
  my($self)=shift;

  for my $p (@{$self->{select}{node}}) {
    $p->parentNode()->removeChild($p)
  }
}

sub Apply {
  my($self)=shift;
  my($fh) = *STDOUT;

  # to bypass an Inkscape bug : make sure SVG current-layer is set !
  $self->{document}{namedview}->setAttribute("inkscape:current-layer", $self->{document}{current_layer}{id});

  binmode($fh);
  $self->{XML}{dom}->toFH($fh);
  exit(1);
}

sub new {
  my($class)=shift;
  my($self) = { argv => join(' ', @_) };

  my $InitXML = sub {
    my($svg)=shift;
    my($dom, $xpc);

        -e $svg
    and $dom=XML::LibXML->load_xml(location => $svg)
    or  die "DOM creation failed!\n";
        $xpc = XML::LibXML::XPathContext->new($dom)
    or  die "XPath evaluator creation failed!\n";

    #register namespaces used by Inkscape DTD
    for(keys(%_NS)) {
      $xpc->registerNs($_ => $_NS{$_});
    }

    return($dom, $xpc);

  };

  my $InitDocument = sub {
    my($xpc)=$self->{XML}{xpc};
    my($node);
    my(%attrs);
    my(@r);


    my $PathSelection = sub { #($self->{args}{id};
      my($objs)=shift;
      my($GetPaths); # Pre-declare sub for recursive call
      my($layer);
      my(@paths);

      $GetPaths = sub {
        my($node)=shift;
        my($type)=$node->nodeName();
        my($GetLayer); # Pre-declare sub for recursive call
        my($translate);

        $GetLayer = sub {
          my($node)=shift;

              $node->getAttribute('inkscape:groupmode')
          and $node->getAttribute('inkscape:groupmode') eq 'layer'
          and return $node;

             (    $node=$node->parentNode() 
              and $node->nodeName() ne 'svg')
          or  die gettext("Selected object is outside any layer (Inkscape bug!).")."\n";

              
          return &$GetLayer($node);
        };

          $type eq 'path'
        and do { 
          push(@paths, { map { $_->nodeName() => $_->value() } $node->attributes() } );
          $paths[-1]{node} = $node;
          $paths[-1]{layer}{node} = &$GetLayer($node);
          $paths[-1]{layer}{id} = $paths[-1]{layer}{node}->getAttribute('id');
          return;
        };

          $type !~ /^g|#text$/
        and die gettext("Selected object is not a segment.")."\n";

        for my $node ($node->childNodes()) {
          &$GetPaths($node);
        }
      };

      for my $obj (@$objs) {
        my($node)= $xpc->findnodes("//*[\@id=\"$obj\"]");

        push(@{$self->{select}{node}},$node);

        &$GetPaths($node);
        $layer or $layer=$paths[-1]{layer}{id};

            $layer eq $paths[-1]{layer}{id}
        or  die gettext("Selected objects must be in the same layer.")."\n"; 
      }

            @paths
        or  return [];

      return([@paths])
    };
      
    my $PointSelection = sub { #($self->{args}{selected_nodes};
      my($objs)=shift;
# Ignore for now : TODO
      return [];
    };

    my $GetCurrentLayer = sub {
      my($name)=shift;
      my($node);
      my($current_layer)={};

          $name
      and $node = @{$xpc->findnodes("./svg:svg/svg:g[\@id=\"$name\"]")}[0];
 
          $node
      or  do {
                @{$self->{select}{path}}
            or  die gettext("Inkscape bug : current layer is not defined.")."\n";

            $node=$self->{select}{path}[-1]{layer}{node};
            warn sprintf(gettext("Inkscape bug : current layer is not defined, forced to %s.")."\n",$self->{select}{path}[-1]{layer}{id});
      };

      $current_layer->{node} = $node;

      $current_layer->{id}=$node->getAttribute('id');
      $current_layer->{transform}=$node->getAttribute('transform');

      
      $current_layer->{transform} = 0;
      
          defined $current_layer->{transform}
      and $current_layer->{transform} = $current_layer->{transform} =~ /^translate\($re_num,($re_num)\)$/ ? $1 : 0;
          
      return($current_layer);
    };

       $node = @{$xpc->findnodes('./svg:svg')}[0]
    or die "Not a SVG document: missing 'svg' element.\n";

    # Get SVG parameters
        $self->{document}{svg}{viewbox} = $node->getAttribute('viewBox')
    or  die "Invalid SVG document: missing 'viewbox' attribute.\n";
    $self->{document}{svg}{viewbox}=[ split('\s+',$self->{document}{svg}{viewbox}) ];
        $self->{document}{svg}{height} = _Dim2Pixel($self, $node->getAttribute('height'))
    or  die "Invalid SVG document: missing 'height' attribute.\n";
        $self->{document}{svg}{width} = _Dim2Pixel($self, $node->getAttribute('width'))
    or  die "Invalid SVG document: missing 'width' attribute.\n";

    # Get nameview paramaters
        $node = @{$xpc->findnodes('./svg:svg/sodipodi:namedview')}[0]
    or  die "Not an Inkscape document: missing 'namedview' element.\n";

    $self->{document}{namedview} = $node;

    $self->{document}{lockguides} = $node->getAttribute('inkscape:lockguides');
    $self->{document}{units} = $node->getAttribute('units');

    # Get selection
    $self->{select}{path}=&$PathSelection($self->{args}{id});
    $self->{select}{point}=&$PointSelection($self->{args}{selected_nodes});

    $self->{document}{current_layer} = &$GetCurrentLayer($node->getAttribute('inkscape:current-layer'));

        @{$self->{select}{path}}
    and $self->{select}{path}[0]{layer}{id} ne $self->{document}{current_layer}{id}
    and die gettext("Selected objects must be in the current layer.")."\n";

  };

  my $ParseOptions = sub {
    my(@cmd) = @_;
    my(@id, @selected_nodes, $svg);
    my($vars) = {};

    my($Vars) = sub {
      my($var)=shift;

        $var =~/^--([^=]+)=(.*)$/
      or die "Unknown option: $var";
      $vars->{$1}=$2;
    
    };

    $cmd[-1]="--svg=".$_[-1];

    Getopt::Long::Configure ("pass_through");

    GetOptionsFromArray(\@cmd,"svg:s" => \$svg, "id:s" => \@id, "selected-nodes:s" => \@selected_nodes, '<>' => $Vars);

    $vars->{id}= [ @id ];
    $vars->{selected_nodes}= [ @selected_nodes ];
    $vars->{svg}= $svg;

    $vars;
    
  };


  $self->{args}=&$ParseOptions(@_);

  @{$self->{XML}}{"dom", "xpc"}=&$InitXML($self->{args}{svg});

  &$InitDocument();

  bless($self, $class);
};

1;
