use strict;
use warnings;
use utf8;
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

push @functions_m, [sub {return (substr($_[0], 0, 1) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], 0, 2) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], 0, 3) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], 0, 4) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], -1) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], -2) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], -3) , "YES")},1];
push @functions_m, [sub {return (substr($_[0], -4) , "YES")},1];

sub percs {
    my $word = shift;
    my $what = shift;
    my $sstr = shift;
    
    #say "Poustim sstr u $word - $what - $sstr";

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


sub get_sub {
    my $number = shift;
    my $where = shift;
    my $howmuch = shift;
    return [sub{percs($_[0], $where, $number)}, $howmuch];
}

sub get_subs_with_same_nu {
    my $nu = shift;
    my $hm = shift;
    return map {
        my $k = $_;
        my @res;
        if ($nu!=0) {
            @res = (get_sub($nu, $k, $hm), get_sub(-$nu, $k, $hm));
        } else {
            @res = (get_sub($nu, $k, $hm));
        }
        @res
    } ("pred", "pred2", "za", "za2")
}

my @tri = get_subs_with_same_nu(3, 40);
my @dva = get_subs_with_same_nu(2, 20);
my @jedna = get_subs_with_same_nu(1,10);
if (((scalar @tri) + (scalar @dva) + (scalar @jedna))!=24) {
    die "Misto 24 jich je".((scalar @tri) + (scalar @dva) + (scalar @jedna));
}
my @nula = get_subs_with_same_nu(0,40);

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


sub de_diacritics{
    my $w = shift;
    $w=lc($w);
    $w=~s/ô/ovokan/g;
    $w=~s/ë/eprehl/g;
    $w=~s/\\/backslashznak/g;
    $w=~s/ä/ae/g;
    $w=~s/á/aacute/g;
    $w=~s/ç/cturek/g;
    $w=~s/ć/cacute/g;
    $w=~s/č/ccaron/g;
    $w=~s/ď/dcaron/g;
    $w=~s/é/eacute/g;
    $w=~s/ě/ecaron/g;
    $w=~s/í/iacute/g;
    $w=~s/ň/ncaron/g;
    $w=~s/ó/ocaron/g;
    $w=~s/[őö]/oe/g;
    $w=~s/[ľĺ]/lcaron/g;
    $w=~s/ř/rcaron/g;
    $w=~s/ŕ/racute/g;
    $w=~s/š/scaron/g;
    $w=~s/ť/tcaron/g;
    $w=~s/ý/yacute/g;
    $w=~s/[úů]/uacute/g;
    $w=~s/ą/a/g;
    $w=~s/ü/ue/g;
    $w=~s/ž/zcaron/g;
    $w=~s/\=/rvn/g;
    $w=~s/%/procentosign/g;
    $w=~s/\*/hvezdasign/g;
    $w=~s/\˙/wtfsign/g;
    $w=~s/ˇ/carsign/g;
    $w=~s/¨/eesign/g;
    $w=~s/</lessth/g;
    $w=~s/>/biggth/g;
    $w=~s/@/at/g;
    $w=~s/§/para/g;
    $w=~s/\s+/sss/g;
    $w=~s/'/apos/g; 

    if ($w !~ /^(\d+)_[a-z0-9]+$/) {
        say "DIVNY: $w";
        $w=~s/[^_a-z0-9]/divny/g;
    }
    return $w;
}


sub write_out {

    my $name=shift;
    my $fname = "arff/$name.arff";
    #my $mincount = shift;
    say "====META === $name";
    my $t = localtime;
    say "TIME: $t";
    my @functions_counts=@_;
    my @functions = map {$_->[0]} @functions_counts;
    my %min_counts;
    @min_counts{1..scalar @functions} = map{$_->[1]} @functions_counts;
    
    my %is_numeric;

    my $i=0;
    for my $function (@functions) {
        $i++;
        for my $word (keys %categories_for_word) {
            my %results = $function->($word);
            RESKEY:
            for my $result_key (keys %results) {
                if ($result_key eq "") {
                    next RESKEY;
                }
                my $k = de_diacritics($i."_".$result_key);
                $obrmatice{$k}{$word}=$results{$result_key};
                if ($results{$result_key} eq "YES") {
                    $is_numeric{$k}=0;
                } else {
                    $is_numeric{$k}=1;
                }
            }
        }
    }

    my @words = keys %categories_for_word;
    my @feats = keys %obrmatice;

    @feats = grep {
        my $key = $_;
        $key =~ /^(\d+)_/ or die "wrong key $key";
        my $num = $1;
        my $mincount = $min_counts{$num};
        (keys %{$obrmatice{$key}} > $mincount)# && (keys %{$obrmatice{$key}} < (@words - $mincount));
    
    } @feats;

    print scalar @feats;
    die "LOL";


    my $vzdalenost_od_prumeru = sub {
        my $key = shift;
        my $size = scalar keys %{$obrmatice{$key}};
        return abs($size - (scalar @words)/2);
    };
    @feats = sort {
        $vzdalenost_od_prumeru->($a) <=> $vzdalenost_od_prumeru->($b)
    } @feats;
    my $max_feats=200;
    @feats = @feats[0..200];




    #print scalar @feats;
    #exit;

    #print join(" ", @feats); #print "\n";

    open my $featurefile, ">", $fname or die $!;

    use 5.010;
    
    say $featurefile "\@relation $name";
    say $featurefile "";

    
    for my $feat(@feats) {
        print $featurefile "\@attribute $feat ";
        if ($is_numeric{$feat}) {
            say $featurefile "numeric";
        } else {
            say $featurefile "{0,1}";
        }
    }
    for my $cat (@rozumne) {
        say $featurefile "\@attribute TAG_$cat {0,1}";
    }

    say $featurefile "";
    say $featurefile "\@data";

    for my $word (@words) {
        for my $feat (@feats) {
            if (exists $obrmatice{$feat}{$word}) {
                my $v = $obrmatice{$feat}{$word};
                if ($v eq "YES") {$v=1}
                print $featurefile $v;
            } else {
                print $featurefile 0;
            }
            print $featurefile ",";
        }
        for my $type(@rozumne) {
            if (exists $categories_for_word{$word}{$type}) {
                print $featurefile "1";
            } else {
                print $featurefile "0";
            }
            if ($type ne $rozumne[-1]) {
                print $featurefile ",";
            }
        }


        print $featurefile "\n";
    }


    say "====TABULKA DONE===";


}

#do_experiment("morhpho1_copy", @functions_m);
#do_experiment("kontext", @functions_k);
#do_experiment("komplik", @functions_komplik);
#do_experiment("kontext_v1", @functions_k);
#do_experiment("komplik_v1",  ( @functions_komplik));

#write_out("all_feat",  (@functions_m));
write_out("all_feat",  (@nula ));
#write_out("all_feat",  (@tri, @dva, @jedna, @nula, @functions_m));



#do_experiment("random_total",  (@functions_random));

#do_experiment("bag_h2",  (@functions_m, @functions_k, @functions_komplik));
#do_experiment("small_bag_h1",  (@functions_m, @functions_k));
#do_experiment("bag_h2",  (@functions_m, @functions_k, @functions_komplik));
