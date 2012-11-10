use strict;
use warnings;

use 5.010;


my %categories_for_word;


binmode (STDOUT, ":utf8");

open my $slovnik, "<:utf8", "data/ruslan-feats/slovnik.features" or die $!;

my %feature_counts;

while (my $data=<$slovnik>) {
    chomp($data);
    my ($f, $s, undef) = split (/\t+/, $data);
    $f =~ s/\(//g;
    $f =~ s/\)//g;
    $f =~ s/\*//g;
    my @cats = grep {length($_)>0} split(/\s*,\s*/, $f);
    my %cats_h; 
    @cats_h{@cats}=();
    
    for (@cats) {
        $feature_counts{$_}++;
    }

   # $categories_for_word{$s} = \%cats_h;
}

close $slovnik;


my @good_features = sort {$feature_counts{$b}<=> $feature_counts{$a}} grep {$feature_counts{$_}>=10} keys %feature_counts;  

my $sum=0;
for (@good_features) {$sum+=$feature_counts{$_}}

say $sum;
