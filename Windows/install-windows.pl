use strict;
use warnings;

use Cwd qw/cwd abs_path/;
use Win32;
use File::Basename;
use File::Copy::Recursive qw/rcopy rmove_glob pathmk pathrmdir/;

my($wperlExe);
my($homeDir, $inkDir);
my($inkExtDir, $srcExtDir, $srcLocale, $dstLocaleInk, $dstLocaleOri);
my($srcPerllibDir, $dstPerllibDir);

$SIG{__DIE__} = sub { $^S and return; Win32::MsgBox(shift, MB_ICONEXCLAMATION, 'Origami-Ext Installation') };

sub ExecCmd {
	my($prg)=shift;
	my($cmd)=$prg;
	my(@args)=@_;
	my($log);

	for (@args) {
				$_ =~ /\ /
		and $_="'$_'";
	}

	$cmd=$prg.' '.join(' ',@args);
	$log=`$cmd 2>&1`;
			$?
	and die "Error executing: >$prg<:\n$log\n";
}


sub Init {

			Win32::IsAdminUser()
	or  die "Must be run as Admin.\n";

			@ARGV
	or die "Installation directory not specified.\n";

  $homeDir=$ARGV[0];

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
			$inkDir
	or	die "Inkscape directory not found.\n(Is Inkscape installed?)\n";

	$wperlExe=dirname(qq/$^X/).'/wperl.exe';

			-f $wperlExe
	or  die "wperl.exe not found.\n\n(Is Active Perl installed?)\n";

	# Change potential relative pathes to absolute ones
  $homeDir=abs_path($homeDir);
	$wperlExe=abs_path($wperlExe);
	$inkDir=abs_path($inkDir);

	# Check if wperl and GNU gettext utilities can be run on this system
	# (--help is a hack for the program to return anyway as they all accept
	# this switch as a valid one
	ExecCmd($wperlExe, '--help');
	ExecCmd("$homeDir/Windows/msgcat.exe", '--help');
	ExecCmd("$homeDir/Windows/msgfmt.exe", '--help');
	ExecCmd("$homeDir/Windows/msgunfmt.exe", '--help');

	$srcLocale="$homeDir/I18n/locale";
			-d $srcLocale
	or die "Directory\n\n$srcLocale\n\nnot found.\n";

	$dstLocaleInk="$inkDir/share/locale";
			-d $dstLocaleInk
	or die "Directory\n\n$dstLocaleInk\n\nnot found.\n";

	$inkExtDir="$inkDir/share/extensions";
		 -d $inkExtDir
	or die "directory\n\n$inkExtDir\n\nnot found.\n";

	$srcExtDir="$homeDir/Origami";
		 -d $srcExtDir
	or die "directory\n\n$srcExtDir\n\nnot found.\n";

	$srcPerllibDir="$homeDir/perl-libs";
		 -d $srcPerllibDir
	or die "Directory\n\n$srcPerllibDir\n\nnot found.\n";

	$dstLocaleOri="$inkExtDir/Origami/locale";
	$dstPerllibDir="$inkExtDir/Origami/perllib";
}

sub InstallBase {

	# Check if XML::LibXML is installed
	# if not, try to install it
			eval "require XML::LibXML"
  or	do {
		my($log);
		print("Adding Perl module XML:PerlXML (this may take a while)...");
		$log=`ppm install XML::LibXML 2>&1`;
				$?
		and die "Installtion of XML::PelXML module failed:\n\n$log\n";
		print "done.\n";
	};
			eval "require XML::LibXML"
  or	do {
		die "Module XML::LibXML not available despite installation\n";
	};

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

	my $InstallLocaleOri = sub {
		my($src)="$srcLocale/$_";
		my($dst)="$dstLocaleOri/$_/LC_MESSAGES";

		pathmk($dst);
		chdir($dst);

		rcopy("$src/Origami.po","./Origami.po");
		ExecCmd("$homeDir/Windows/msgfmt.exe", '-o', "./Origami.mo", "./Origami.po");
		unlink("./Origami.po");
	};

	my $InstallLocaleInk = sub {
		my($src)="$srcLocale/$_";
		my($dst)="$dstLocaleInk/$_/LC_MESSAGES";

		chdir($dst);

		# if a backup aleready exists, restore it
				-f	"./inkscape-orig.mo"
		and	rcopy("./inkscape-orig.mo", "./inkscape.mo");

		rcopy("./inkscape.mo", "./inkscape-orig.mo");
		rcopy("$src/Origami-Ext.po","./Origami-Ext.po");
		ExecCmd("$homeDir/Windows/msgunfmt.exe", '-o', "./inkscape.po", "./inkscape.mo");
		ExecCmd("$homeDir/Windows/msgcat.exe", '--use-first', '-o', './inkscape.po', './inkscape.po', "./Origami-Ext.po");
		ExecCmd("$homeDir/Windows/msgfmt.exe", '-o', './inkscape.mo', './inkscape.po');
		unlink('.\inkscape.po');
		unlink('.\Origami-Ext.po');
	};

	# First, try to get a working gettext for Origami=Ext messages
			eval "Require Locale::gettext"
	or	do { # Try to install Locale::gettext (will probably fail)
		`ppm install Locale::Gettext 2>&1`;
				$?
		and do { # Failed. So install the Pure Perl Locale::gettext_basic
						 # provided by Origami-Ext and set @INC accordingly
			rcopy("$homeDir/Perl-Libs/*","$inkExtDir/Origami/perllib");
			push(@INC, "$inkExtDir/Origami/perllib");
		};
	};

	# Check if we now have a working gettext available
			eval "require Locale::gettext"
	or	eval "require Locale::gettext_basic"
	or	die "Cannot install a working gettext";

	# Install all provided translations
	for (map {basename($_) } <$srcLocale/*>) {
				(-f "$srcLocale/$_/Origami.po" and -f "$srcLocale/$_/Origami-Ext.po")
		or	next;
		print "Installing locale '$_'...";
		&$InstallLocaleOri($_);
	  &$InstallLocaleInk($_);
		print "done.\n";
	}

}

Init();

			Win32::MsgBox("Everything looks good, ready to install.\n\nShall we proceed?", 33, 'Origami-Ext Installation') == 2
and	die "Installation aborted.\n";

InstallBase();
InstallLocales();

Win32::MsgBox("Intallation succeded.", MB_ICONINFORMATION, 'Origami-Ext Installation');

#printf "homeDir=>%s<\n", $homeDir;
#printf "inkDir=>%s<\n", $inkDir;
#printf "wperlExe=>%s<\n", $wperlExe;
#printf "srcLocale=>%s<\n", $srcLocale;
#printf "dstLocaleInk=>%s<\n", $dstLocaleInk;
#printf "inkExtDir=>%s<\n", $inkExtDir;
#printf "srcExtDir=>%s<\n", $srcExtDir;
#printf "dstLocaleOri=>%s<\n", $dstLocaleOri;
#printf "srcPerllibDir=>%s<\n", $srcPerllibDir;
#printf "dstPerllibDir=>%s<\n", $dstPerllibDir;
