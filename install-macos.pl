#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use POSIX qw/setlocale LC_MESSAGES/;
use Cwd qw/abs_path/;
use Config;


    $Config{osname} ne 'darwin'
and die "Sorry, you're not on a Linux system. Aborting installation.\n";

    $>
and die "You must sudo to run this script. Aborting installation.\n";

my($ori_ext)='Origami-Ext';
my($ori_ink)='Origami-Ink';
my($pwd)=dirname(abs_path(__FILE__));
my($exedir);
my($extdir);


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

  #  print "$cmd\n";
  system $cmd;
}

sub Prepare {
  my($aptupdate)=0;

  my $InstModule = sub {
    my($name)=shift;
    my($pkg)=shift;

        eval "require $name"
    or  do {
          FindExecDir('dpkg')
      or  die "Perl module $name not installed and your system doen't use dpkg : you'll have to install it yourself. Aborting Installation.\n"; 

          Prompt("Perl module $name not installed. Do you want me to install it ? [Y/n] : ","YN") eq 'Y'
      and do {
        my($stdout, $err);

              $aptupdate
        or  do {
          print "Doing apt-update... ";
          $stdout=`apt-get update 2>&1`;
              ($?>>8) != 0
          and die "failed: \n$stdout\n\nAborting installation.\n";
          ++$aptupdate;
          print "done.\n";
        };

        print "Installing or updating package: '$pkg'... ";

        $stdout=`apt-get -qy install $pkg 2>&1`;
            ($?>>8) != 0
        and die "failed: \n$stdout\n\nAborting installation.\n";

        print "done.\n";
   
      };

          eval "require $name"
      or  die "Perl module $name not availaible. Aborting installation.\n";
    };

  };


      $exedir = FindExecDir('inkscape')
  or  die "Cannot find inkscape executable in \$PATH : is Inkscape installed ? Aborting installation.\n";

  $extdir = "$exedir/../share/inkscape/extensions";
      -d  $extdir
  or  die "Something seems wrong : cannot find Inkscape extensions directory!. Aborting installation.)\n";

  &$InstModule("XML::LibXML",'libxml-libxml-perl');
  &$InstModule("Locale::gettext",'liblocale-gettext-perl');
}

sub Install {

    my $InstallExtension = sub {
        not -d "$extdir/Origami"
    and ExecCmd("mkdir $extdir/Origami");

    ExecCmd("cp $pwd/Origami/*.pm $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.pl $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.inx $extdir");
  };

  my $InstallLocales = sub {

    my $InstallLocale = sub {
      my($lang)=shift;
      my($srcdir)="$pwd/I18n/locale/$lang";
      my($localedir)="$exedir/../share/locale/$lang/LC_MESSAGES";
      # Extension Messages

      ExecCmd("msgfmt -o $localedir/$ori_ext.mo $srcdir/$ori_ext.po");

      # Inkscape Messages

      # If re-install, restore original inkscape.mo file
          -e  "$localedir/inkscape-orig.mo"
      and ExecCmd("cp $localedir/inkscape-orig.mo $localedir/inkscape.mo");

      ExecCmd("cp $localedir/inkscape.mo $localedir/inkscape-orig.mo");
      ExecCmd("msgunfmt -o $localedir/inkscape.po $localedir/inkscape.mo");
      ExecCmd("msgcat --use-first -o $localedir/inkscape.po $localedir/inkscape.po $srcdir/$ori_ink.po");
      ExecCmd("msgfmt -o $localedir/inkscape.mo $localedir/inkscape.po");
      ExecCmd("rm $localedir/inkscape.po");

    };

    my(@locales)=map { substr($_,-2,2) } <$pwd/I18n/locale/*>;

    for my $locale (@locales) {


      # Does this locale exists for inkscape and
      # fully exists for Origami-Ext ?
         (    -f "$exedir/../share/locale/$locale/LC_MESSAGES/inkscape.mo"
          and -f "$pwd/I18n/locale/$locale/$ori_ext.po"
          and -f "$pwd/I18n/locale/$locale/$ori_ink.po")
      or  next;
      &$InstallLocale($locale);
    }


  };

  &$InstallExtension();
  &$InstallLocales();

}

sub Remove {
  my(@locales);
  my(@modules);


  # First, restore inkscape.mo in each locale
  # and delete $ori_ext.po
  @locales=map { substr($_,-2,2) } <$pwd/I18n/locale/*>;
  for my $locale (@locales) {
    my($localedir)="$exedir/../share/locale/$locale/LC_MESSAGES";
        -f "$localedir/inkscape-orig.mo"
    and ExecCmd("mv $localedir/inkscape-orig.mo $localedir/inkscape.mo");
        -f "$localedir/$ori_ext.mo"
    and ExecCmd("rm $localedir/$ori_ext.mo");
  }
  # Now remove .inx from .pl list
  @modules=<$extdir/Origami/*.pl>;
  for my $module (@modules) {
    $module =~ s|Origami/||;
    $module =~ s/\.pl$/.inx/;
    ExecCmd("rm $module");
  }
  # Finally remove Origami from extension dir
  ExecCmd("rm -r $extdir/Origami");
}

# Main()

Prepare();

    # Check if installed
    -d "$extdir/Origami"
and do {
  my($choice);

  print "Origami-Ext already installed on this computer.\n";
  $choice=Prompt("What do you want to do : (R)einstall, (S)uppress or (Q)uit ? [r/s/Q]:",'QRS');
    $choice eq 'S'
  and do {
    # Confirm removal
        Prompt("Are you sure you want to remove the Origami Extension ? [y/N]:", 'NY') eq 'N'
    and die "Removal of Origami Extension aborted.\n";
    Remove();
    print("Origami-Ext has been successfully removed.\n");
    exit(1);
  };
    $choice eq 'R'
  and do {
    Remove();
    Install();
    print("Origami-Ext has been successfully reinstalled.\n");
    exit(1);
  };
  exit(1);
};

Install();

print "Origami-Ext successfully installed.\n";

exit(1);
