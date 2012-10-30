use strict;
use warnings;

$|=1;


my $number = $ARGV[0];

open my $f, "<:utf8", "data/slovnik.cz";
my %slovnik_words;
while (my $w = <$f>) {
    chomp($w);
    $slovnik_words{$w} = undef;
}


my $megaregexp = join("|", keys %slovnik_words);
$megaregexp = "(".$megaregexp.")";

#print $megaregexp;

close $f;

print "OK\n";
open my $sen, "<:utf8", "data/sentences";

my $good;
my $all;

while (my $l = <$sen>) {
    chomp($l);
    my $is_good=0;
#    for my $k (keys %slovnik_words) {
    my @words = split(/\s+/, $l);
    my $goodw = scalar grep {/$megaregexp/i} @words;
    
        if ($goodw>=$number) {
            $is_good=1;
        }
#    }
    if ($is_good) {
        $good++;
    }
    $all++;
    #print "|\n";
}

print $good/$all;
print "\n";

