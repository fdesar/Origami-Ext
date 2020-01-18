use strict;
use warnings;

use Cwd qw/cwd abs_path/;
use Win32;
use File::Basename;
use File::Copy::Recursive qw/rcopy fmove rmove_glob pathmk pathrmdir/;
use File::Path qw/remove_tree/;


my($wperlExe);
my($homeDir, $inkDir);
my($inkExtDir, $srcExtDir, $srcLocale, $dstLocale);
my($srcPerllibDir, $dstPerllibDir);
my($ori_ext)='Origami-Ext';
my($ori_ink)='Origami-Ink';
my($action);
my($perlpath)='';


$SIG{__DIE__} = sub { $^S and return; Win32::MsgBox(shift, MB_ICONEXCLAMATION, 'Origami-Ext Installation') };

sub SetPerlPath {

        eval { require Win32::Env };
    not $@
    and do {
        my($addpath) = shift;
        my($path);
        my($regexp);

        $path = Win32::Env::GetEnv(0, 'PATH'); 
        $addpath=~s/\\perl(?:.exe)?$//;

        $regexp = $addpath;
        $regexp =~ s/\\/\\\\/g;

            $path !~ /$regexp/
        and do {
            $path =~ s/\s*;$//;
            $path .= ";$addpath;";
            Win32::Env::SetEnv(0, 'PATH', $path);
            Win32::Env::BroadcastEnv();
        };
    };
}

sub ExecCmd {
    my($prg);
    my($cmd);
    my(@args)=@_;
    my($log);

    for (@args) {
        $_ =~ s/\//\\/g;
        $_ =~ /\ / and $_="\"$_\"";
    }

    $cmd=join(' ',@args);

    $log=`$cmd 2>&1`;
			$?
    and die sprintf("Error executing: >%s<:\n%s", $args[0], $log);

}

sub Init {

    my $CheckModule = sub {
      my($module)=shift;

      # Check if $module is installed
      # if not, Active Perl is probably used : try to install it with ppm
      eval "require $module";
      $@ ne '' and do {
	 my($log);
	 print("Adding Perl module $module (this may take a while)...");
	 $log=`ppm install $module 2>&1`;
	      $?
	  and die "Installation of $module module failed:\n\n$log\n";
          print "done.\n";
          eval "require $module";
             $@ eq ''
          or die "Module $module still not available : you're probably not using Active Perl !\n";
      };
    };

#    &$CheckModule("Win32::Env");
    &$CheckModule("XML::LibXML");
    
        (defined($ARGV[0]) and $ARGV[0] =~ /^(UN)?INSTALL$/)
    or  die("This Perl script must not be run directly : \nRun the script install-windows.cmd instead\n");

    $action=$ARGV[0];

    defined($ARGV[1]) and $perlpath=$ARGV[1];


    $homeDir=dirname(abs_path(__FILE__));
    $homeDir=~s|[/\/][^/\/]+$||;

        -f $homeDir.'/Windows/'.basename(__FILE__)
    or	die "Invalid installation directory:\n\n$ARGV[0]\n";

    # Search Inkscape directory
    for my $path ('C:/Program Files', 'C:/Program Files (x86)') {
            -d $path.'/Inkscape'
        and	do {
            $inkDir=$path.'/Inkscape';
            last;
        }
    }
        -d $inkDir
    or	die "Inkscape directory not found.\n(Is Inkscape installed?)\n";

    $wperlExe=dirname(qq/$^X/).'/wperl.exe';

        -f $wperlExe
    or  die "wperl.exe not found.\n\n(Which version of Perl are you using ?)\n";

	# Change potential relative pathes to absolute ones
  $homeDir=abs_path($homeDir);
	$wperlExe=abs_path($wperlExe);
	$inkDir=abs_path($inkDir);

	# Check if wperl and GNU gettext utilities can be run on this system
	# (--help is a hack for the program to return anyway as they all accept
	# this switch as a valid one
	ExecCmd("$wperlExe", '--help');
	ExecCmd("$homeDir/Windows/msgcat.exe", '--help');
	ExecCmd("$homeDir/Windows/msgfmt.exe", '--help');
	ExecCmd("$homeDir/Windows/msgunfmt.exe", '--help');

	$srcLocale="$homeDir/I18n/locale";
			-d $srcLocale
	or die "Directory\n\n$srcLocale\n\nnot found.\n";

	$dstLocale="$inkDir/share/locale";
			-d $dstLocale
	or die "Directory\n\n$dstLocale\n\nnot found.\n";

	$inkExtDir="$inkDir/share/extensions";
		 -d $inkExtDir
	or die "directory\n\n$inkExtDir\n\nnot found.\n";

	$srcExtDir="$homeDir/Origami";
		 -d $srcExtDir
	or die "directory\n\n$srcExtDir\n\nnot found.\n";

	$srcPerllibDir="$homeDir/perl-libs";
		 -d $srcPerllibDir
	or die "Directory\n\n$srcPerllibDir\n\nnot found.\n";

	$dstPerllibDir="$inkExtDir/Origami/perllib";
}

sub InstallBase {

	# Copy wperl.exe as perl.exe to the Inkscape directory
	# to avoid black command window when running
	rcopy($wperlExe, $inkDir.'/perl.exe');

	# Install extension
	rcopy($srcExtDir, $inkExtDir.'/Origami');
	rmove_glob("$inkExtDir/Origami/*.inx", $inkExtDir);

	print "Origami-Ext base installed.\n";

}

# NOTE:
# msg* executables are very picky about how the system give their args,
# specially when whitespaces appear in filenames, so always chdir
# to dstdir and copy src files to dst dir to alway call them just
# prefixed with './', then unlink the copied src file afterwards.
sub InstallLocales {

	my $InstallLocale = sub {
		my($src)="$srcLocale/$_";
		my($dst)="$dstLocale/$_/LC_MESSAGES";

		chdir($dst);

		# if a backup aleready exists, restore it
				-f	"./inkscape-orig.mo"
		and	rcopy("./inkscape-orig.mo", "./inkscape.mo");

		rcopy("$src/$ori_ext.po","./$ori_ext.po");
		ExecCmd("$homeDir/Windows/msgfmt.exe", '-o', "./$ori_ext.mo", "./$ori_ext.po");
		unlink("./$ori_ext.po");

		rcopy("./inkscape.mo", "./inkscape-orig.mo");
		rcopy("$src/$ori_ink.po","./$ori_ink.po");
		ExecCmd("$homeDir/Windows/msgunfmt.exe", '-o', "./inkscape.po", "./inkscape.mo");
		ExecCmd("$homeDir/Windows/msgcat.exe", '--use-first', '-o', './inkscape.po', './inkscape.po', "./$ori_ink.po");
		ExecCmd("$homeDir/Windows/msgfmt.exe", '-o', './inkscape.mo', './inkscape.po');
		unlink('./inkscape.po');
		unlink("./$ori_ink.po");
	};

	# As Locale::Gettext is not implemented on Win32 because of lacking libintl DLL
	# install our own Locale::gettext_basic
	rcopy("$homeDir/Perl-Libs/*","$inkExtDir/Origami/perllib");
	push(@INC, "$inkExtDir/Origami/perllib");
	
	# Check now if Locale::gettext_basic is available
		eval "require Locale::gettext_basic"
	or	die "Cannot have a working Locale::gettext_basic module";

	# Install all provided translations
	for (map {basename($_) } <$srcLocale/*>) {
				(-f "$srcLocale/$_/$ori_ext.po" and -f "$srcLocale/$_/$ori_ink.po")
		or	next;
		print "Installing locale '$_'...";
		&$InstallLocale($_);
		print "done.\n";
	}
}

sub Remove {
  my(@modules);
  my(@locales);

  my $CleanupPath = sub {
    my($path);

    eval "require Win32::Env";
       $@ eq ''
    or return;

        $^X =~ /\\Inkscape\\Perl5/
    and do {
        $path=Win32::Env::GetEnv(0, 'PATH');
        $path =~ s/;.*?\\Perl5//;
        Win32::Env::SetEnv(0, 'PATH', $path);
        Win32::Env::BroadcastEnv();
    };
  };

  chdir($dstLocale);
  @locales=map { basename($_)."/LC_MESSAGES" } <"$srcLocale/*">;
  for my $locale (@locales) {
        -f "./$locale/$ori_ext.mo"
    and unlink("./$locale/$ori_ext.mo");
        -f "./$locale/inkscape-orig.mo"
    and fmove("./$locale/inkscape-orig.mo","./$locale/inkscape.mo");
  }

  # Remove .inx files
  chdir($inkExtDir);

  @modules= map { s/\.pl$/\.inx/; $_ } map { basename($_) } <"./Origami/*.pl">;
  for (@modules) {
    unlink("./$_");
  }
  remove_tree("./Origami");
	unlink($inkDir.'/perl.exe');
  &$CleanupPath();
}

Init();


if ($action eq 'INSTALL') { # Install
         Win32::MsgBox("Everything looks good, ready to install.\n\nShall we proceed?", 
                      36, 'Origami-Ext Installation') == 7
    and die "Installation aborted.\n";

  InstallBase();
  InstallLocales();

  $perlpath ne '' and $perlpath ne 'NONE' and SetPerlPath($perlpath); 

  Win32::MsgBox("Intallation completed.", MB_ICONINFORMATION, 'Origami-Ext Installation');
} else { # Uninstallation
         Win32::MsgBox("Origami-Ext already installed: do you want to uninstall it?",
                       36, 'Origami-Ext Installation') == 7
    and die "Uninstallation aborted.\n";

  Remove();

  Win32::MsgBox("Uninstallation completed.", MB_ICONINFORMATION, 'Origami-Ext Installation');
}
