#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use POSIX qw/setlocale LC_MESSAGES/;
use Cwd qw/abs_path/;
use Config;


    $Config{osname} ne 'linux'
and die "Sorry, you're not on a Linux system. Aborting installation.\n";

my($oripo)='Origami.po';
my($oriextpo)='Origami-Ext.po';

my($lang);
my($inst_type);
my($pwd)=dirname(abs_path(__FILE__));
my($langdir)="$pwd/I18n/locale/";
my($home)=$ENV{HOME};
my($uid)=(stat __FILE__)[4];
my($user)=(getpwuid $uid)[0];
my($exedir);
my($extdir);
my($localedir);


sub Prompt {
  my($msg,$choice)=@_;
  my($default)=substr($choice,0,1);
  my($r);

  $choice="[$choice]";


  while (1) {
    print $msg;
    $r=readline(STDIN);
    defined($r) or next;
    chomp($r);
        ($r eq '' or  $r =~ /^$choice$/i)
    and last;
  }

      $r eq ''
  and $r=$default;

  return uc($r);

}

sub FindExecDir {
  my($prg)=shift;
  my($dir);
  my(@path)=split(':',$ENV{PATH});

  for my $path (@path) {
      -e "$path/$prg"
    and return $path; # Found
  }
  return ''; # Not found
}

sub ExecCmd {
  my($cmd)=shift;

  # print "$cmd\n";
  system $cmd;
}

    $exedir = FindExecDir('inkscape')
or  die "Cannot find inkscape executable in \$PATH (is Inkscape installed ?). Aborting installation.\n";

    eval { require XML::LibXML }
or  die "You should first install Lib::LibXML for Perl. Aborting installation.\n";

$lang=substr(setlocale(LC_MESSAGES),0,2);
#$lang='de';
$langdir .= $lang;

   (    -d $langdir
    and -f "$langdir/$oripo"
    and -f "$langdir/$oriextpo")
or  $langdir="";

if($langdir) {
  my($has_gettext);
  print "Translation found for your language '$lang'";
  $has_gettext=FindExecDir('gettext');

  if($has_gettext) {
    print " and GNU gettext available.\n";
  }
  else {
    $lang=$langdir='';
    print " but GNU gettext not available.";
        Prompt(" Install without translation anyway [y/N] ?",'NY') ne 'Y'
    and die "Aborting installation.\n";
  }

}
else {
  warn "\nSorry, no translation available for your current language '$lang'.\n\n";
  $lang='';
}

$localedir="$exedir/../share/locale/$lang/LC_MESSAGES";

    $lang
and (not -d $localedir or not -f "$localedir/inkscape.mo")
and die "Cannot find Inkscape translation messages for '$lang'. Aborting installation.\n";

$inst_type=Prompt("Do you want a (U)ser or a (S)ystem installation ? [U/s] : ","US");

$extdir = $inst_type eq 'U' ? "$home/.config/inkscape/extensions"
                            : "$exedir/../share/inkscape/extensions";

    $inst_type ne 'U'
and $user='root';

    -d  $extdir
or  die "Something seems wrong : cannot find Inkscape extensions directory!. Aborting installation.)\n";

    ($lang or $inst_type eq 'S')
and $>
and die "You need to run this script as root to make this installation. Aborting installation.\n";

# Now we have everything set up to instal...

# Install extension

ExecCmd("sudo -u $user mkdir $extdir/Origami");
ExecCmd("sudo -u $user cp $pwd/Origami/*.pm $extdir/Origami");
ExecCmd("sudo -u $user cp $pwd/Origami/*.pl $extdir/Origami");
ExecCmd("sudo -u $user cp $pwd/Origami/*.inx $extdir");

    $lang
and do {
  ExecCmd("sudo -u $user mkdir $extdir/Origami/locale");
  ExecCmd("sudo -u $user mkdir $extdir/Origami/locale/$lang");
  ExecCmd("sudo -u $user mkdir $extdir/Origami/locale/$lang/LC_MESSAGES");
  ExecCmd("sudo -u $user cp $pwd/Origami/locale/$lang/LC_MESSAGES/Origami.mo $extdir/Origami/locale/$lang/LC_MESSAGES/Origami.mo");
};

# Install Inkscape locale

print "\n";

    $lang
and do {
      -e  "$localedir/inkscape-orig.mo"
  and ExecCmd("cp $localedir/inkscape-orig.mo $localedir/inkscape.mo");

  ExecCmd("cp $localedir/inkscape.mo $localedir/inkscape-orig.mo");
  ExecCmd("msgunfmt -o $localedir/inkscape.po $localedir/inkscape.mo");
  ExecCmd("msgcat --use-first -o $localedir/inkscape.po $localedir/inkscape.po $pwd/I18n/locale/$lang/Origami-Ext.po");
  ExecCmd("msgfmt -o $localedir/inkscape.mo $localedir/inkscape.po");
  ExecCmd("rm $localedir/inkscape.po");
};

print "Installation completed successfully.\n";
