#this script is very "quick and dirty"


use strict;
use warnings;


#gets unique members of array
sub get_uniq {
    my @w = @_;
    if (scalar @w==0) {die "OOPS"}
    my %h; @h{@w}=();
    return keys %h;
}

my %category_for_word;

binmode (STDOUT, ":utf8");

open my $slovnik, "<:utf8", "data/slovnik.features";

while (my $line = <$slovnik>) {
    chomp $line;
    my ($cats, undef, $rus) = split(/\t/, $line);

    $cats =~ /\*([^,\)]+)/;
    my $cat = $1;
    if (!$cat) {
        $cat = "UNK";
    }
    $category_for_word{$rus} = $cat;

}
close $slovnik;


my %counts;

open my $factored, "<:utf8", "data/factored.ru";
while (my $line = <$factored>) {
    chomp $line;
    $line =~ s/^\s+//;
    
    my @corpus_lemmas = map {my(undef, $r, undef) = split(/\|/, $_); $r} split(/\s+/, $line);
    for my $i (0..$#corpus_lemmas) {
        my $lemma = $corpus_lemmas[$i];
        if (exists $category_for_word{$lemma}) {
            $counts{$lemma}++;
        }
    }
}

close $factored;

#elite == words, that are more than 20 times :)
my @elite = grep {($counts{$_}||0)>20} keys %category_for_word;
my %elite_hash; @elite_hash{@elite}=();


#this is just renumbering the categories
#from letters to numbers 1..16
my %category_renum;
@category_renum{get_uniq(@category_for_word{@elite})}=(1..scalar keys %category_for_word);


my %counts_where_before;
my %counts_where_after;
my %counts_where_before_sum;
my %counts_where_after_sum;

open  my $factored2, "<:utf8", "data/factored.ru";
while (my $line = <$factored2>) {
    chomp $line;
    $line =~ s/^\s+//;
    
    my @corpus_lemmas = map {my(undef, $r, undef) = split(/\|/, $_); $r} split(/\s+/, $line);
    for my $i (0..$#corpus_lemmas) {
        my $lemma = $corpus_lemmas[$i];
        if (exists $elite_hash{$lemma}) {
            my $lemma_before = ($i==0)? "BEGIN" : $corpus_lemmas[$i-1];
            my $lemma_after = ($i==$#corpus_lemmas) ? "END":$corpus_lemmas[$i+1];
            $counts_where_before{$lemma_before}{$lemma}++;
            $counts_where_after{$lemma_after}{$lemma}++;
            $counts_where_before_sum{$lemma_before}++;
            $counts_where_after_sum{$lemma_after}++;
        }
    }
}
close $factored2;
#my $context_words = (scalar keys %counts_where_before) + (scalar keys %counts_where_after);

my @words_before = grep {$counts_where_before_sum{$_}>40} keys %counts_where_before;
my @words_after = grep {$counts_where_after_sum{$_}>40} keys %counts_where_after;


open my $fcr, ">", "regression/features";
for my $word (@elite) {
    for my $word_before (@words_before) {
         print $fcr $counts_where_before{$word_before}{$word} || 0;
         print $fcr " ";
    }
    for my $word_after (@words_after) {
         print $fcr $counts_where_after{$word_after}{$word} || 0;
        print $fcr " ";
    }
    print $fcr "\n";
}

open my $ctg, ">", "regression/categories";
for my $word (@elite) {
    print $ctg $category_renum{$category_for_word{$word}}."\n";
}

#print $context_words."\n";
