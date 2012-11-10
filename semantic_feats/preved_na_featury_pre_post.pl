use strict;
use warnings;

use 5.010;

my @rozumne  = qw(A C R K V H Z M P N F D);

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

    $categories_for_word{$s} = \%cats_h;
}

close $slovnik;


#my @good_features = sort {$feature_counts{$b}<=> $feature_counts{$a}} grep {$feature_counts{$_}>=10} keys %feature_counts;  

#print join " ", @good_features;
#print "\n";


#this is just renumbering the categories
#from letters to numbers 1..16
#my %category_renum;
#@category_renum{@good_features}=(1..scalar @good_features);


my %obrmatice;



my @functions;

#push @functions, sub {return (substr($_[0], 0, 1) , 20)};
#push @functions, sub {return (substr($_[0], 0, 2) , 20)};
#push @functions, sub {return (substr($_[0], 0, 3) , 20)};
#push @functions, sub {return (substr($_[0], 0, 4) , 20)};
#push @functions, sub {return (substr($_[0], -1) , 20)};
#push @functions, sub {return (substr($_[0], -2) , 20)};
#push @functions, sub {return (substr($_[0], -3) , 20)};
#push @functions, sub {return (substr($_[0], -4) , 20)};

sub percs {
    my $word = shift;
    my $what = shift;
    my $dir = "data/webcol_$what"."_perc";
    if (!-e $dir."/$word") {
        return ();
    }

    my %res;
    open my $f, "<:utf8", $dir."/$word";
    while (my $l=<$f>) {
        chomp($l);
        my ($n, $w) = split(/\t/, $l);
        if ($n!=0) {
            $res{$w}=$n;
        }
    }
    return %res;
}
my $pre = sub {
    return percs($_[0], "pred");
};
my $za = sub {
    return percs($_[0], "za");
};
my $pre2 = sub {
    return percs($_[0], "pred2");
};
my $za2 = sub {
    return percs($_[0], "pre2"); 
};

push @functions, $pre, $za, $pre2, $za2;

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

@feats = grep {keys %{$obrmatice{$_}} > 5} @feats;

#print scalar @feats;
#exit;

#print join(" ", @feats);
#print "\n";

mkdir "ML_tables";
open my $featurefile, ">", "ML_tables/features" or die $!;

use 5.010;
my @words = keys %categories_for_word;

for my $word (@words) {
    for my $feat (@feats) {
        if (exists $obrmatice{$feat}{$word}) {
            print $featurefile $obrmatice{$feat}{$word};
        } else {
            print $featurefile 0;
        }
        print $featurefile " ";
    }
    print $featurefile "\n";
}

for my $type (@rozumne) {
    
    open my $catfile, ">", "ML_tables/is$type" or die $!;
    for my $word (@words) {

        if (exists $categories_for_word{$word}{$type}) {
            print $catfile "1";
        } else {
            print $catfile "0";
        }
        print $catfile "\n";
    }
    close $catfile;
}


