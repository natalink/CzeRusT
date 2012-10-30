use strict;
use warnings;




my %categories_for_word;

binmode (STDOUT, ":utf8");

open my $slovnik, "<:utf8", "data/slovnik.features";

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

    $categories_for_word{$s} = \%cats_h;
}

close $slovnik;


my @good_features = sort {$feature_counts{$b}<=> $feature_counts{$a}} grep {$feature_counts{$_}>=10} keys %feature_counts;  

#print join " ", @good_features;
#print "\n";


#this is just renumbering the categories
#from letters to numbers 1..16
my %category_renum;
@category_renum{@good_features}=(1..scalar @good_features);


my %obrmatice;



my @functions;

push @functions, sub {return (substr($_[0], 0, 1) , 20)};
push @functions, sub {return (substr($_[0], 0, 2) , 20)};
push @functions, sub {return (substr($_[0], 0, 3) , 20)};
push @functions, sub {return (substr($_[0], 0, 4) , 20)};
push @functions, sub {return (substr($_[0], -1) , 20)};
push @functions, sub {return (substr($_[0], -2) , 20)};
push @functions, sub {return (substr($_[0], -3) , 20)};
push @functions, sub {return (substr($_[0], -4) , 20)};


my $i=0;
for my $function (@functions) {
    $i++;
    for my $word (keys %categories_for_word) {
        my %results = $function->($word);
        for my $result_key (keys %results) {
            my $k = $i.":".$result_key;
            $obrmatice{$k}{$word}=$results{$result_key};
        }
    }
}

my @feats = keys %obrmatice;

@feats = grep {keys %{$obrmatice{$_}} > 1} @feats;

#print join(" ", @feats);
#print "\n";


open my $featurefile, ">", "ML_tables/features";
open my $catfile, ">", "ML_tables/category";

use 5.010;
for my $word (keys %categories_for_word) {
    for my $feat (@feats) {
        if (exists $obrmatice{$feat}{$word}) {
            print $featurefile $obrmatice{$feat}{$word};
        } else {
            print $featurefile 0;
        }
        print $featurefile " ";
    }
    print $featurefile "\n";

    
    if (exists $categories_for_word{$word}{"H"}) {
        print $catfile "1";
    } else {
        print $catfile "0";
    }
    print $catfile "\n";
}


