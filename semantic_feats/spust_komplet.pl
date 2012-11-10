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



my @functions_m;

push @functions_m, [sub {return (substr($_[0], 0, 1) , 20)},1];
push @functions_m, [sub {return (substr($_[0], 0, 2) , 20)},1];
push @functions_m, [sub {return (substr($_[0], 0, 3) , 20)},1];
push @functions_m, [sub {return (substr($_[0], 0, 4) , 20)},1];
push @functions_m, [sub {return (substr($_[0], -1) , 20)},1];
push @functions_m, [sub {return (substr($_[0], -2) , 20)},1];
push @functions_m, [sub {return (substr($_[0], -3) , 20)},1];
push @functions_m, [sub {return (substr($_[0], -4) , 20)},1];

sub percs {
    my $word = shift;
    my $what = shift;
    my $sstr = shift;
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
            my $what;
            if (!$sstr) {
                $what = $w;
            } elsif ($sstr>0) {
                $what = substr($w, 0, $sstr);
            } elsif ($sstr <0) {
                $what = substr($w, $sstr);
            }

            $res{$what}+=$n;
        }
    }
    return %res;
}
my $pre = [sub {
    return percs($_[0], "pred");
}, 5];
my $za = [sub {
    return percs($_[0], "za");
},5];
my $pre2 = [sub {
    return percs($_[0], "pred2");
},5];
my $za2 = [sub {
    return percs($_[0], "pre2"); 
},5];
my @functions_k;
push @functions_k, $pre, $za;#, $pre2, $za2;

my @prem = map {[sub {
    return percs($_[0], "pred", $_);
}, 50]} (-4..-1, 1..4);
my @zam = map {[sub {
    return percs($_[0], "za", $_);
}, 50]} (-4..-1, 1..4);
my @pre2m = map {[sub {
    return percs($_[0], "pred2");
},50]} (-4..-1, 1..4);
my @za2m = map {[sub {
    return percs($_[0], "pre2"); 
}, 50]} (-4..-1, 1..4);
my @functions_komplik = (@prem, @zam);#, @pre2m, @za2m);

my $randum = sub {
    my %res;
    for my $i (1..100) {
        my $t = rand();
        if ($t>0.5) {
            $res{$i}=1;
        } else {
            $res{$i}=0;
        }
    }
    return %res;
};
my @functions_random = ([$randum, 5]);


sub do_experiment {

    my $name=shift;
    #my $mincount = shift;
    say "====META === $name";
    my $t = localtime;
    say "TIME: $t";
    my @functions_counts=@_;
    my @functions = map {$_->[0]} @functions_counts;
    my %min_counts;
    @min_counts{1..scalar @functions} = map{$_->[1]} @functions_counts;
    

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

    my @words = keys %categories_for_word;
    my @feats = keys %obrmatice;

    @feats = grep {
        my $key = $_;
        $key =~ /^(\d+):/ or die "wrong key $key";
        my $num = $1;
        my $mincount = $min_counts{$num};
        (keys %{$obrmatice{$key}} > $mincount) #&& (keys %{$obrmatice{$key}} < (@words - $mincount));
    } @feats;



    #print scalar @feats;
    #exit;

    #print join(" ", @feats); #print "\n";

    mkdir "ML_tables";
    open my $featurefile, ">", "ML_tables/features" or die $!;

    use 5.010;

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

    say "====TABULKA DONE, hledani lamd===";

    system "cd regression; perl run.pl $name";
    say "====LAMDY DONE, vyhodnocovani===";
    system "cd regression; perl runfinal.pl $name";

}

#do_experiment("morhpho1_copy", @functions_m);
#do_experiment("kontext", @functions_k);
#do_experiment("komplik", @functions_komplik);
#do_experiment("kontext_v1", @functions_k);
#do_experiment("komplik_v1",  ( @functions_komplik));

#do_experiment("bag_v1",  (@functions_m, @functions_k, @functions_komplik));
do_experiment("random_total",  (@functions_random));

#do_experiment("bag_h2",  (@functions_m, @functions_k, @functions_komplik));
#do_experiment("small_bag_h1",  (@functions_m, @functions_k));
#do_experiment("bag_h2",  (@functions_m, @functions_k, @functions_komplik));
