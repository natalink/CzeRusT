use strict;
use warnings;

$|=1;


my $number = $ARGV[0];

open my $f, "<:utf8", "data/ruslan-feats/slovnik.cz" or die $!;
my %slovnik_words;
while (my $w = <$f>) {
    chomp($w);
    $w=lc($w);
    $slovnik_words{$w} = 0;
}



#print $megaregexp;

close $f;

open my $webcoll, "<:utf8", "data/webcoll/slovnik.cetnosti" or die $!;

while (my $l = <$webcoll>) {
    chomp($l);
    $l=lc($l);

    my ($c, $w) = $l =~ /^(\d+) (.*)$/ or die $l;
#   for my $k (keys %slovnik_words) {
   
    if (exists $slovnik_words{$w}) {
          $slovnik_words{$w}+=$c;
    } 
    
    
    #print "|\n";
}

use 5.010;

binmode(STDOUT, ":utf8");

for (keys %slovnik_words) {
    say $_, "\t", $slovnik_words{$_}
}

#print scalar grep {$slovnik_words{$_} >=10} keys %slovnik_words;
#print "\n";

