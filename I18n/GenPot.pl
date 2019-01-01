#!/opt/local/bin/perl

use strict;
use warnings;
use utf8;
use POSIX;
use File::Basename;
use XML::LibXML;
use XML::LibXML::XPathContext;
use Cwd 'abs_path';

setlocale(LC_ALL,"en_US.UTF-8");

#my @LINGUAE=qw/fr de it/;
my @LINGUAE=qw/fr/;


sub PotHeader {
  my($header)=<<EOT
msgid "" 
msgstr ""
"POT-Creation-Date: %s\\n"
"PO-Revision-Date: %s\\n"
"Language-Team: <origami.ext\@gmail>\\n"
"Project-Id-Version: initial\\n"
"Last-Translator: Francois Desarmenien\\n"
"Language: C\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"X-Generator: Origami-Ext/GenPot\\n"

EOT
;
  
  my $TimeStamp = sub {
    my($sec, $min, $hour, $mday, $mon, $year, $wday,$ yday, $isdst)=gmtime(time);
    return sprintf("%04d-%02d-%02d %02d:%02d UTC", $year+1900, $mon+1, $mday, $hour, $min);
  };

  return sprintf($header, &$TimeStamp(), &$TimeStamp()); 

}


# A few directories definitions
my($cur_dir)=dirname(abs_path(__FILE__)); # Directory where of this program is executed
my($inkscape_root);  # Where is the current inkscape executable
my($mess_root);  # Where the LINGUAE messages are"

# This should be computed
$inkscape_root="/usr/local/bin";
$mess_root=$inkscape_root.'/../share/locale';


sub Init {
  # First, verify we are located in the right place
      (-d "$cur_dir/../I18n" and -d "$cur_dir/../Origami-Ext")
  or  die "This utility should be located in the Inkscape-Ext/I18n extension directory\n";

  # Copy inkscape.mo to inkscape-orig.mo for each supported locale
  for my $ling (@LINGUAE) {
    my($mo) = "$mess_root/$ling/LC_MESSAGES/inkscape.mo";
        -e $mo
    or warn "$mo file not found: unable to copy inkscape.mo for locale '$ling'.\n";

      -d $ling
    or mkdir($ling, 0755);

    system("cp $mo $ling/inscape-orig.mo")
  }
}

sub GenInxPot {
  my($potfile)="$cur_dir/Inkscape-Ext.pot";
  my(@inx)=<../Origami-Ext/*.inx>;
  my(%msg);
  my($dom);

  my $WritePot = sub {
    my($fh);

    open($fh,">$potfile")
    or  die "Cannot create $potfile\n";
    print $fh PotHeader();

    for (keys(%msg)) {
      my($msg)=$_;
      printf$fh ("#: %s\n", join(' ', @{$msg{$_}}));
      $msg =~s/^\s*|\s*$//g;
      $msg =~s/\n/\\n"\n "/g;
      printf$fh ("msgid \"%s\"\nmsgstr \"\"\n\n",$msg);
    }

    close($fh);
  };

  my($Follow); # Recursive anonymous sub
  $Follow = sub {
    my($filename)=shift;
    my($node)=shift;
    my(@attributes)=$node->attributes();

    for my $att (@attributes) {
        $att->nodeName() =~/^_/
      and do {
        my($txt)=$att->value();
        utf8::encode($txt);
        push(@{$msg{$txt}},sprintf("%s:%s", basename($filename), $att->line_number));
      };
    }
    for my $node ($node->childNodes()) {
          $node->nodeName =~/^_/
      and do {
        my($txt)=$node->textContent();
        $txt =~ s/\n/\\n/g;
        utf8::encode($txt);
        push(@{$msg{$txt}},sprintf("%s:%s", basename($filename), $node->line_number));
      };
      &$Follow($filename, $node);
    }
  };

  for my $filename (@inx) {
    $dom=XML::LibXML->load_xml(location => $filename, line_numbers => 1);
    &$Follow($filename, $dom->findnodes('/'));
  }

  &$WritePot();
}

sub GenScriptPot {
  my($potfile)="$cur_dir/Origami.pot";
  my(@inx)=(<../Origami-Ext/*.pl>, <../Origami-Ext/*.pm>);
  my(%msg);

  my $WritePot = sub {
    my($fh);

    open($fh,">$potfile")
    or  die "Cannot create $potfile\n";
    print($fh PotHeader());

    for (sort { $a cmp $b } keys(%msg)) {
      my($msg)=$_;
      printf$fh ("#: %s\n", join(' ', @{$msg{$_}}));
      $msg =~s/^\s*|\s*$//g;
      $msg =~s/\n/\\n"\n "/g;
      printf$fh ("msgid \"%s\"\nmsgstr \"\"\n\n",$msg);
    }

    close($fh);
  };

  my $Messages = sub {
    my($fname)= shift;
    my($fh);
    my($lineno)=0;

    open($fh,"<$fname")
    or  die "Cannot open $fname though it exists !\n";

    while (! eof($fh)) {
      my($line);

      $lineno++;
          defined($line = readline($fh))
      or die "Error reading $fname line $lineno!\n";
            $line =~ /^\s*#/
        and next;
        $line =~ /gettext\s*\(\s*"(((?:\")|[^"])*)"\s*\)/
      and do {
        my($txt)=$1;
        utf8::encode($txt);
        push(@{$msg{$txt}},sprintf("%s:%s", basename($fname), $lineno));
      };
    };
  };

  for my $filename (@inx) {
    &$Messages($filename);
  }

  &$WritePot();
}

Init();
# Generate Origami.pot file to Pot dir
GenInxPot();
GenScriptPot();
