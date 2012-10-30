use warnings;
use strict;
use utf8;

binmode(STDOUT, ":utf8");

my %counts;

open my $slovnik, "<:utf8", "data/slovnik.features";
while (my $data=<$slovnik>) {
    chomp($data);
    my ($f, $s, undef) = split (/\t+/, $data);
    $f =~ s/\(//g;
    $f =~ s/\)//g;
    $f =~ s/\*//g;
    my @cats = split(/\s*,\s*/, $f);
    for (@cats) {$counts{$_}++ if(length($_)>0)}
}

for (sort {$counts{$b}<=>$counts{$a}} keys %counts) {
    print "".$_."\t".$counts{$_}."\n";
}

