#!/usr/bin/perl


#########################################################################
#                                                                       #
# This program is copyrigh 2018, François Désarménien                   #
#                                                                       #
# LICENCE : this Free Software : you may use it and distribute it under #
#           the terms of the GNU GPLv2 licence or either the terms of   #
#           the Inkcape license itself.                                 #
#                                                                       #
#########################################################################

use strict;
use warnings;

use POSIX;
use Config;

use File::Basename;
use Cwd 'abs_path';
use lib dirname(abs_path(__FILE__));

use Origami;

sub _GetLang {
  my($locale);
  my($os)=$Config{osname};

      eval '&POSIX::LC_MESSAGES'
  and do {
    $locale=setlocale(LC_MESSAGES,'');
    return lc(substr($locale,0,2));
  };

  # We are running on a bloated scrap windoze
      $Config{osname} eq 'MSWin32'
  and do {
       $locale = eval("use Locale::WinLocale; MSLocale()")
    or return 'C';
    return lc(substr($locale,0,2));
  };
  return('C');
}

my($locale)=_GetLang();
my($pdf)=dirname(abs_path(__FILE__))."/Manual/$locale/HandBook.pdf";

-e $pdf or $pdf=dirname(abs_path(__FILE__))."/Manual/en/HandBook.pdf";

  -e $pdf
or do {
    -e $pdf or die gettext("Origami-Ext HanBook not found!")."\n";
  exit(0);
};

sub ShowPDF {
    my ($url) = @_;
    my $action = {
        MSWin32 => sub { $url=~s/\//\\/g; qx/explorer.exe "$url"/ },
        darwin  => sub { system qq{open "$url" >/dev/null 2>&1 &} },
    }->{$^O}    || sub { system qq{xdg-open "$url" >/dev/null 2>&1 &} };
    $action->();
}

ShowPDF $pdf;

exit(1);
