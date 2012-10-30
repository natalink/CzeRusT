use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");


#open my $wat, "<:utf8", "data/precision_recall_based_on_PDT";
open my $wat, "<:utf8", "wat";

my $beta = $ARGV[0];

my %scores;

while (my $l=<$wat>) {
    chomp($l);
    my ($koncovka, $rys, $p, $r) = split(/\t/, $l);
    if ($p ==0 || $r==1) {
        ;
    #    print 3;
    } else {
        $koncovka=~s/\s//g;

#        my $beta = 1;
        
        my $score= ((1+$beta*$beta)*($p*$r)/($beta*$beta*$p+$r));
        my $line = $koncovka."\t".$rys."\t".$score."\t".$p."\t".$r;
        
        $scores{$line}=$score;
        
    }
}


for my $line (sort {$scores{$b} <=> $scores{$a}} keys %scores) {
    print $line."\n";
}
