use strict;
use warnings;

my %yes_animated;
my %no_animated;

binmode (STDOUT, ":utf8");

open my $animSlovnik, "<:utf8", "data/animacy.feat";

while (my $line = <$animSlovnik>) {
    chomp $line;
    $line =~ /^(.*)\|H$/ or die "wrong format";
    
    my $word = $1;
    $yes_animated{lc($word)}=1; 
}
close $animSlovnik;


open my $nonanimSlovnik, "<:utf8", "data/nonanimated.ru";

while (my $line = <$nonanimSlovnik>) {
    chomp $line;
    
    my $word = $line;
    $no_animated{lc($word)}=0; 
}
close $nonanimSlovnik;


#my %counts;
#
#open my $factored, "<:utf8", "factored.ru";
#while (my $line = <$factored>) {
#    chomp $line;
#    $line =~ s/^\s+//;
#    
#    my @corpus_lemmas = map {my(undef, $r, undef) = split(/\|/, $_); $r} split(/\s+/, $line);
#    for my $i (0..$#corpus_lemmas) {
#        my $lemma = $corpus_lemmas[$i];
#        if (exists $category_for_word{$lemma}) {
#            $counts{$lemma}++;
#        }
#    }
#}
#
#close $factored;

#elite == words, that are more than 20 times :)
open my $factored, "<:utf8", "data/factored.ru";

my %counts;
while (my $line = <$factored>) {
    chomp $line;
    $line =~ s/^\s+//;
    
    my @corpus_lemmas = map {my(undef, $r, undef) = split(/\|/, $_); lc($r)} split(/\s+/, $line);
    for my $i (0..$#corpus_lemmas) {
        my $lemma = $corpus_lemmas[$i];
        if (exists $yes_animated{$lemma} || exists $no_animated{$lemma}) {
            $counts{$lemma}++;
        }
    }
}

close $factored;
use 5.010;
say "OMG";
say scalar keys %yes_animated;
say scalar keys %no_animated;
#elite == words, that are more than 20 t))imes :)
my @elite_no = grep {($counts{$_}||0)>=1} ((keys %no_animated));
my @elite_yes = grep {($counts{$_}||0)>=1} ((keys %yes_animated));
my @elite = (@elite_no, @elite_yes);
my %elite_hash; @elite_hash{@elite}=();

say scalar @elite_yes;
say scalar @elite_no;

#my %elite_hash; @elite_hash{@elite}=();


#this is just renumbering the categories
#from letters to numbers 1..16
#my %category_renum;
#@category_renum{get_uniq(@category_for_word{@elite})}=(1..scalar keys %category_for_word);


my %counts_where_before;
my %counts_where_after;
my %counts_where_before_sum;
my %counts_where_after_sum;

open  my $factored2, "<:utf8", "data/factored.ru";
while (my $line = <$factored2>) {
    chomp $line;
    $line =~ s/^\s+//;
    
    my @corpus_POSs = map {my(undef, undef, $tag) = split(/\|/, $_); $tag=~/^(.)/; $1} split(/\s+/, $line);
    my @corpus_lemmas = map {my(undef, $r, undef) = split(/\|/, $_); $r} split(/\s+/, $line);
    for my $i (0..$#corpus_lemmas) {
        my $lemma = $corpus_lemmas[$i];
        if (exists $elite_hash{$lemma}) {
#            my $lemma_before = ($i==0)? "BEGIN" : $corpus_lemmas[$i-1];
            my $lemma_after = ($i==$#corpus_lemmas) ? "END":$corpus_lemmas[$i+1];
            my $POS_after = ($i==$#corpus_POSs)? ".":$corpus_POSs[$i+1];
            if ($POS_after eq "N") {

 #           $counts_where_before{$lemma_before}{$lemma}++;
                $counts_where_after{$lemma_after}{$lemma}++;
                #$counts_where_before_sum{$lemma_before}++;
                $counts_where_after_sum{$lemma_after}++;
            }
        }
    }
}
close $factored2;
#my $context_words = (scalar keys %counts_where_before) + (scalar keys %counts_where_after);

#my @words_before = grep {$counts_where_before_sum{$_}>300} keys %counts_where_before;
my @words_after = grep {$counts_where_after_sum{$_}>1} keys %counts_where_after;


open my $fcr, ">", "regression/features" or die $!;
open my $ctg, ">", "regression/categories" or die $!;
for my $word (keys %elite_hash) {
    #for my $word_before (@words_before) {
    #     print $fcr $counts_where_before{$word_before}{$word} || 0;
    #     print $fcr " ";
    #}
    for my $word_after (@words_after) {
         print $fcr $counts_where_after{$word_after}{$word} || 0;
        print $fcr " ";
    }
    print $fcr "\n";

    print $ctg ($yes_animated{$word}?1:0)."\n";
}

#for my $word (@elite) {
#    print $ctg $category_renum{$category_for_word{dd$word}}."\n";
#}

#print $context_words."\n";
