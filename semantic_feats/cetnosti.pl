use warnings;
use strict;

binmode(STDOUT, ":utf8");

my %counts;
my %reverse_feature_hash;

open my $slovnik, "<:utf8", "data/slovnik.features";
while (my $data=<$slovnik>) {
    chomp($data);
    my ($f, $s, undef) = split (/\t+/, $data);
    
    $f =~ s/\(//g;
    $f =~ s/\)//g;
    $f =~ s/\*//g;
    my @cats = grep {length($_)>0} split(/\s*,\s*/, $f);
 
    $counts{$s} = 0;
   
    for (@cats) {
        push @{$reverse_feature_hash{$_}}, $s;
    }
}

close $slovnik;

my %counts_left;
my %counts_right;

$|=1;
open my $pdt, "<:utf8", "data/sentences";
while (my $sentence = <$pdt>) {
    chomp($sentence);
    $sentence=~s/^\s+//;
    $sentence=~s/\s+$//;

    my @words = split (/\s+/, $sentence);
    @words = ("BEGIN", @words, "END");
    for my $i (1..$#words-1) {
        
        my $prev_word = $words[$i-1];
        my $word = $words[$i];
        my $next_word = $words[$i+1];

        
        #for my $word (@words) {
            if (exists $counts{$word}) {
                $counts{$word}++;
                $counts_left{$word}{$prev_word}++;
                $counts_right{$word}{$next_word}++;
            }
        #}
    }
}

use 5.010;
for my $feature (keys %reverse_feature_hash) {
    if (scalar @{$reverse_feature_hash{$feature}} > 8) {
        say "FEATURA ".$feature;

        my @best = sort {$counts{$b}<=>$counts{$a}}  @{$reverse_feature_hash{$feature}};
        for my $word (@best[0..1]) {
            say "  word: ".$word;
            my @best_left = sort {$counts_left{$word}{$b}<=>$counts_left{$word}{$a}} keys %{$counts_left{$word}};
            for my $left_word (@best_left[0..1]) {
                say "      left:".$left_word;
            }
            my @best_right = sort {$counts_right{$word}{$b}<=>$counts_right{$word}{$a}} keys %{$counts_right{$word}};
            for my $right_word (@best_right[0..1]) {
                say "      right:".$right_word;
            }
        }
    }
}
