use strict;
use warnings;

my($fh);
my($count);

my($fname)="inkscape-orig.po";

my(%msgid);

    open($fh,'<',$fname)
or  die "Cannot open $fname";

while (! eof($fh)) {
  my($line);
      defined($line = readline($fh))
  and $line =~ /^msgid\s"((?:\\"|[^"])+)"/
  and $1 ne ''
  and do {
    ++$msgid{$1};
    ++$count;
  };
}

close($fh);

$fname="Origami-Ext.po";

    open($fh,'<',$fname)
or  die "Cannot open $fname";

while (! eof($fh)) {
  my($line);
      defined($line = readline($fh))
  and $line =~ /^msgid\s"((?:\\"|[^"])+)"/
  and $1 ne ''
  and do {
        exists($msgid{$1})
    and printf("'$1' : collision !\n");
  };
}

close($fh);

printf("%d keys found.\n", $count);
