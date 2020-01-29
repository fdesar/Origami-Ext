#!/opt/local/bin/perl

use strict;
use warnings;
use File::Basename;
use POSIX qw/setlocale LC_MESSAGES/;
use Cwd qw/abs_path/;
use Config;

$SIG{__DIE__} = sub { $^S and return; printf "$_[0]\nAborting installation.\n\nPress <RETURN>"; readline() };

$Config{osname} ne 'darwin'
and die "Sorry, you're not on a MacOS system.\n";

$>
and do {
	printf "\nPerforming sudo to execute installation.\n";
	exec("sudo $^X ".__FILE__);
};

my($ori_ext)='Origami-Ext';
my($ori_ink)='Origami-Ink';
my($pwd)=dirname(abs_path(__FILE__));
my($exedir);
my($extdir);
my($version)="Unkown version";


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
		my(%modules)=( 'Locale::gettext' => 'p5-locale-gettext',
				'XML::LibXML'     => 'p5-xml-libxml' );
		my($log);

		for my $mod (keys(%modules)) {
		      eval "require $mod"
                  and delete $modules{$mod};
		}

		keys(%modules) == 0 and return;

		FindExecDir("port")
			or  do {
				printf("\nYou are not using the macports version of Inkscape and the following Perl modules are missing:\n\n");
				for (keys(%modules)) {
					printf("-> %s\n", $_);
				}
				die "\n\nCannot install the missing modules : you'll have to do it by yourself (maybe using CPAN ?)\n";
			};

    printf("\nMissing Perl modules:\n\n");
      for (keys(%modules)) {
      printf("-> %s\n", $_);
    }
    my($choice)=Prompt("\nDo you want me to try to install them for you: (Y)es, (N)o ? [Yn]:",'YN');
    $choice eq 'N' and die "\nInstallation aborted.\n";

    printf("Performing 'port selfupdate': this may take a while...");
    $log = qx/port selfupdate 2>&1/;
         $?
    and do {
      die sprintf("\n'port selfupdate' unseccessful. Log:\n\n%s\n",$log);
    };
    printf("done.\n");

    for my $pack (map { $modules{$_} } keys(%modules)) {
      printf("\nInstalling port %s...", $pack);
      $log = qx/port install $pack/;
	  $?
      and die sprintf(" Error during install : %s \n", $log);
      printf("done."); 
    }
    printf("\n\n");
  };

      $exedir = FindExecDir('inkscape')
  or  die "\nCannot find inkscape executable: is Inkscape installed ?\n";

  $extdir = "$exedir/../share/inkscape/extensions";
      -d  $extdir
  or  die "\nSomething seems wrong: cannot find Inkscape extensions directory!.\n";

      (-d $pwd.'/Origami' and -d $pwd.'/I18n')
  or  die "\nYou must run the install program nside its own path !\n";

  # Insure that perms are 644 for files and 755 for directories and executables
  &$SetPerms($pwd);

  &$InstallPackages();
}

# Main Origami-Ext installation: should NOT fail as everything must have been checked before !
#==============================================================================================
sub Install {

    my $InstallExtension = sub {
        not -d "$extdir/Origami"
    and ExecCmd("mkdir $extdir/Origami");

    ExecCmd("cp $pwd/Origami/*.pm $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.pl $extdir/Origami");
    ExecCmd("cp $pwd/Origami/*.inx $extdir");
    ExecCmd("cp -r $pwd/Origami/Manual $extdir/Origami/Manual");
    ExecCmd("cp $pwd/Origami/.version $extdir/Origami/.version");
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

      -e "$extdir/Origami/.version"
  and $version = qx|cat "$extdir/Origami/.version"|;
  printf "\nOrigami-Ext (%s) already installed on this computer.\n\n",$version;
  $choice=Prompt("What do you want to do: (R)einstall, (S)uppress or (Q)uit ? [r/s/Q]:",'QRS');
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

# vim: softtabstop=2:tabstop=2:expandtab
