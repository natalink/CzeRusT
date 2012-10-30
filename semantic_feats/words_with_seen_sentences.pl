use strict;
use warnings;

$|=1;


my $number = $ARGV[0];

open my $f, "<:utf8", "data/slovnik.cz";
my %slovnik_words;
while (my $w = <$f>) {
    chomp($w);
    $slovnik_words{$w} = 0;
}



#print $megaregexp;

close $f;

print "OK\n";
open my $sen, "<:utf8", "data/sentences";

while (my $l = <$sen>) {
    chomp($l);

#    for my $k (keys %slovnik_words) {
    my @words = split(/\s+/, $l);
    
    for my $slovnik_word (keys %slovnik_words) {
        use 5.010;
        if ($slovnik_word ~~ @words) {
            $slovnik_words{$slovnik_word}++;
        }
    }
    
    
    
    #print "|\n";
}

print scalar grep {$slovnik_words{$_} >=1} keys %slovnik_words;
print "\n";

