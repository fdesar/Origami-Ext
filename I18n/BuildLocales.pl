#!/usr/bin/perl


use strict;
use warnings;

use File::Basename;
use Cwd 'abs_path';

my($curDir)=dirname(abs_path(__FILE__)); # Directory where of this program is executed
my($domain)='Origami';


    (-d "$curDir/../I18n" and -d "$curDir/../Origami")
or  die "This utility should be located in the Origami-Ext/I18n extension directory\n";

my(@locales)=map { basename($_) } <$curDir/locale/*>;

    @locales == 0
and die "No locale found.\n";

for my $locale (@locales) {
  print "Building locale for '$locale'...";
      -e "$curDir/../Origami/locale/$locale"
  or  mkdir("$curDir/../Origami/locale/$locale",0755);
      -e "$curDir/../Origami/locale/$locale/LC_MESSAGES"
  or  mkdir("$curDir/../Origami/locale/$locale/LC_MESSAGES",0755);
  system "msgfmt -o $curDir/../Origami/locale/$locale/LC_MESSAGES/$domain.mo $curDir/locale/$locale/$domain.po";
  print "done.\n";
}

