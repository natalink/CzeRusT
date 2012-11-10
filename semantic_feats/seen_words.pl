use strict;
use warnings;

$|=1;


my $number = $ARGV[0];

#open my $f, "<:utf8", "data/ruslan-puvodni/verbs.cz" or die $!;
open my $f, "<:utf8", "data/ruslan-feats/slovnik.cz" or die $!;

my %slovnik_words;
while (my $w = <$f>) {
    chomp($w);
    $w=lc($w);
    $slovnik_words{$w} = 0;
}



#print $megaregexp;

close $f;

print "OK\n";
open my $webcoll, "<:utf8", "data/webcoll/slovnik" or die $!;

while (my $l = <$webcoll>) {
    chomp($l);
    $l=lc($l);

#    for my $k (keys %slovnik_words) {
   
    if (exists $slovnik_words{$l}) {
          $slovnik_words{$l}++;
    } 
    
    
    #print "|\n";
}

print scalar grep {$slovnik_words{$_} >=1} keys %slovnik_words;
print "\n";

