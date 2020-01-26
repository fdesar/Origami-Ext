#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use POSIX qw/setlocale LC_MESSAGES/;
use Cwd qw/abs_path/;
use Config;


    $Config{osname} ne 'linux'
and die "Sorry, you're not on a Linux system. Aborting installation.\n";

    $>
and exec("sudo ".__FILE__);

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
  my($path);
  $path = (qx/which $prg 2>\/dev\/null/)[0];
  $path and $path=~s|/[^/]+$||;
  return $path; 
}

sub ExecCmd {
  my($cmd)=shift;
  system($cmd);
  $? and die "Error executing $cmd\n";
}

sub Prepare {

  my $SetPerms = sub {
    my($root)=shift;
    my(@files)=qx/find $root/;

    for my $file (@files) {
        chomp($file=dirname($file).'/'.basename($file));
            (-d $file or $file=~/\/install-.+\.(pl|cmd)$/)
        and do { chmod(0755, $file); next };
            -f $file
        and chmod(0644, $file);
    }
  };

  my $InstallPackages = sub {
     my(%commands) = ( 
          'dpkg'   => 'apt-get -qy install',
          'yum'    => 'yum -qy install',
          'zypper' => 'zypper install -y',
     );
     my(%updates) = ( 
          'dpkg'   => 'apt -qy update',
          'yum'    => 'yum -qy update',
          'zypper' => 'zypper update -y',
     );
     my %modules=(
        'Exec:msgunfmt'        => { dpkg   => 'gettext',
                                    yum    => 'gettext-tools',
			                              zypper => 'gettext-tools'},
        'Perl:Locale::gettext' => { dpkg   => 'liblocale-gettext-perl',
                                    yum    => 'perl-Locale-gettext',
			                              zypper => 'perl-gettext '},
        'Perl:XML::LibXML',       { dpkg   => 'libxml-libxml-perl',
                                    yum    => 'perl-XML-LibXML',
			                              zypper => 'perl-XML-LibXML'},
        
     );
     my $packager="";
     my $doUpdate=1;

     for (keys(%commands)) {
             FindExecDir($_)
         and do {
             $packager = $_;
             last;
         };
     }

     for my $modname (keys(%modules)) {
        my($modtype);
        $modname =~ /^([^:]+):(.+)$/;
        ($modtype, $modname) = ($1, $2);

            $modtype =~ /^(Perl|Exec)$/
        or  die "Programming error in module tables!\n";

             (    ($modtype eq 'Exec' and FindExecDir($modname))
              or  ($modtype eq 'Perl' and eval "require $modname"))
	       and  next;

	          $packager
         or die sprintf("\nMissing perl Module(s) (%s) on your system and no known packagea found to install them.\n\n",
	                join(', ', map { $_ =~ s/^[^:]+://; $_ } keys(%modules)));
             $doUpdate
         and do {
             $doUpdate=0;
             printf("\nSome needed Packages are missing on your system:\n\n");
             my($choice)=Prompt("Do you want me to try to install them for you : (Y)es, (N)o ? [Yn]:",'YN');
             $choice eq 'N' and die "\nInstallation aborted.\n";
             printf("\nUpdating package list for $packager (this may take a while)...");
             system("$updates{$packager} >/dev/null 2>&1");
             $? and  die "\nUpdating packages failed code $? !\n\n";
             print "done.\n\n";
         };
         printf(qq|Installing Package $modules{"$modtype:$modname"}{$packager}...|);
         system(qq|$commands{$packager} $modules{"$modtype:$modname"}{$packager} >/dev/null 2>&1|);
         $? and die qq|Installing package '$modules{"$modtype:$modname"}{$packager}/ failed !\n\n|;
         print "done.\n\n";

        # Control success !
             (    ($modtype eq 'Exec' and not FindExecDir($modname))
              or  ($modtype eq 'Perl' and not eval "require $modname"))
	       and  die qq|Installing package '$modules{"$modtype:$modname"}{$packager}' failed !\n\n|;
     }
  };


      $exedir = FindExecDir('inkscape')
  or  die "\nCannot find inkscape executable in \$PATH : is Inkscape installed ? Aborting installation.\n";

  $extdir = "$exedir/../share/inkscape/extensions";
      -d  $extdir
  or  die "\nSomething seems wrong : cannot find Inkscape extensions directory!. Aborting installation.)\n";

      (-d $pwd.'/Origami' and -d $pwd.'/I18n')
  or  die "\nYou must run the install program from inside its own path !\n";

  # Insure that perms are 644 for files and 755 for directories and executables
  &$SetPerms($pwd);

  &$InstallPackages();
}

# Main Origami-Ext installation : should NOT fail as everything must have been checked before !
#==============================================================================================
sub Install {

    my $InstallExtension = sub {
        not -d "$extdir/Origami"
    and ExecCmd("mkdir $extdir/Origami");

    ExecCmd("cp $pwd/Origami/*.pm $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.pl $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.inx $extdir");
    ExecCmd("cp -r $pwd/Origami/Manual $extdir/Origami/Manual");
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

    printf("\nInstalling Origami-Ext...\n");

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
# End of Origami-Ext install
#============================

sub Remove {
  my(@locales);
  my(@modules);

  printf("\nRemoving Origami-Ext...\n");

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

  print "\nOrigami-Ext already installed on this computer.\n\n";
  $choice=Prompt("What do you want to do : (R)einstall, (S)uppress or (Q)uit ? [r/s/Q]:",'QRS');
    $choice eq 'S'
  and do {
    # Confirm removal
        Prompt("\nAre you sure you want to remove the Origami Extension ? [y/N]:", 'NY') eq 'N'
    and die "\nRemoval of Origami Extension aborted.\n";
    Remove();
    print("\nOrigami-Ext has been successfully removed.\n\nPress <RETURN>");
    readline();
    exit(1);
  };
    $choice eq 'R'
  and do {
    Remove();
    Install();
    print("\nOrigami-Ext has been successfully reinstalled.\n\nPress <RETURN>");
    readline();
    exit(1);
  };
  exit(1);
};

Install();

print "\nOrigami-Ext successfully installed.\n\nPress <RETURN>";
readline();

exit(1);
