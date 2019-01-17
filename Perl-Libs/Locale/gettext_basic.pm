package Locale::gettext_basic;

use strict;
use warnings;
use POSIX;
use Config;

BEGIN {

  require Exporter;

  our @ISA        = qw(Exporter);
  our @EXPORT     = qw(textdomain bindtextdomain gettext);

}

my %catalogs=();
my $domain;
my $lang='';

sub gettext {
  my($msg)=shift;
      exists($catalogs{$domain})
  and exists($catalogs{$domain}{$msg})
  and return $catalogs{$domain}{$msg};
  return($msg);
}

sub bindtextdomain {
  my($domain, $path)=@_;

      $lang
  or  $lang = _GetLang()
  or  return;

  $path.="/$lang/LC_MESSAGES/$domain.mo";

      not(-f $path and -r $path)
  and return; 

  $catalogs{$domain}=_LoadCatalog($path, $lang);
}

sub textdomain {
  my($newdomain)=shift;

      exists($catalogs{$newdomain})
  or  $catalogs{$newdomain}={};
  $domain=$newdomain;
} 

sub _LoadCatalog
{
    my($filename, $locale) = @_;
    my($filesize, $unpack, $magic);
    my ($revision, $num_strings, $msgids_off, $msgstrs_off, $hash_size, $hash_off); 
    my(@orig_tab, @trans_tab);
    my $messages = {};
    
    # Alternatively we could check the filename for evil characters ...
    # (Important for CGIs).
    return unless -f $filename && -r $filename;
    
    local $/;
    local *HANDLE;
    
        open HANDLE, "<$filename"
    or  return;
    binmode HANDLE;
    my $raw = <HANDLE>;
    close HANDLE;
    
    # Corrupted?
        (not $raw or length($raw) < 28)
    and return;
    
    $filesize = length $raw;
    
    $magic = unpack('N', substr($raw, 0, 4));
    
        $magic != 0xde120495
    and $magic != 0x950412de
    and return;

    $unpack = ($magic == 0xde120495 ? 'V' : 'N');

        ($revision, $num_strings, $msgids_off, $msgstrs_off, $hash_size, $hash_off)
     =  unpack (($unpack x 6), substr $raw, 4, 24);
    
        ($revision >> 16) !=0
    and return;

    return if $msgids_off + 4 * $num_strings > $filesize;
    return if $msgstrs_off + 4 * $num_strings > $filesize;
    
    @orig_tab  = unpack( ($unpack x (2 * $num_strings)), 
    					           substr $raw, $msgids_off, 8 * $num_strings);
    @trans_tab = unpack( ($unpack x (2 * $num_strings)), 
    						         substr $raw, $msgstrs_off, 8 * $num_strings);
    
    
    for (my $count = 0; $count < 2 * $num_strings; $count += 2) {
    	my $orig_length = $orig_tab[$count];
    	my $orig_offset = $orig_tab[$count + 1];
    	my $trans_length = $trans_tab[$count];
    	my $trans_offset = $trans_tab[$count + 1];
    	
    	return if $orig_offset + $orig_length > $filesize;
    	return if $trans_offset + $trans_length > $filesize;
    	
    	my @origs = split /\000/, substr $raw, $orig_offset, $orig_length;
    	my @trans = split /\000/, substr $raw, $trans_offset, $trans_length;
    	
          not($origs[0] and length($origs[0]))
      and next;
      $messages->{$origs[0]}=$trans[0];
    }
    
    return $messages;
}

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

1;
