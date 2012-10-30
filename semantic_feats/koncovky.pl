use warnings;
use strict;
use utf8;
use 5.010;

binmode(STDOUT, ":utf8");

my %kombinace;
my %groups;
open my $slovnik, "<:utf8", "data/slovnik.features";
while (my $data=<$slovnik>) {
    chomp($data);
    my ($f, $s, undef) = split (/\t+/, $data);
    $f =~ s/\(//g;
    $f =~ s/\)//g;
    $f =~ s/\*//g;
    my @cats = grep {length($_)>0} split(/\s*,\s*/, $f);
    my %cats_h; @cats_h{@cats}=();
    
    for (@cats) {
        $groups{$_}++;
    }

    $kombinace{$s} = \%cats_h;
}

my %counts;
open my $pdt, "<:utf8", "data/sentences";
while (my $sentence = <$pdt>) {
    chomp($sentence);
    $sentence=~s/^\s+//;
    $sentence=~s/\s+$//;
    my @words = split (/\s+/, $sentence);
    for my $word (@words) {
        if (exists $kombinace{$word}) {
            $counts{$word}++;
        }
    }
}

close $pdt;

sub true_positive {
    my ($ending, $cat) = @_;
    my $res=0;
    for my $w (keys %kombinace) {
        if ($w =~ /$ending$/) {
            if (exists $kombinace{$w}{$cat}) {
                $res+=($counts{$w}//0);
            }
        }
    }
    return $res;
}

sub all_predicted {
    my ($ending, $cat) = @_;
    my $res=0;
    for my $w (keys %kombinace) {
        if ($w =~ /$ending$/) {
            #if (exists $kombinace{$w}{$cat}) {
                $res+=($counts{$w}//0);
            #}
        }
    }
    return $res;
}

sub all_positive {
    my ($ending, $cat) = @_;
    my $res=0;
    for my $w (keys %kombinace) {
        #if ($w =~ /$ending$/) {
            if (exists $kombinace{$w}{$cat}) {
                $res+=($counts{$w}//0);
            }
        #}
    }
    return $res;
}

sub f_score {
    my ($ending, $cat) = @_;
    my $tp = true_positive($ending, $cat);
    if ($tp==0) {
        return (0,0);
    }
    my $precision = $tp/all_predicted($ending, $cat);
    my $recall = $tp/all_positive($ending, $cat);
    return ($precision, $recall);
 #   return (2*($precision*$recall)/($precision+$recall), $precision);

}

#print f_score("ání", "C");
my %koncovky;


for my $word (keys %kombinace) {
    my $puv = $word;
    while (length $word>0) {
        $koncovky{$word} = undef;
        if (length $word > 1) {
            $word = substr($word, -((length $word)-1));
        } else {
            $word = "";
        }
    }
}

$|=1;
#my %results;
for my $koncovka (keys %koncovky) {
    for my $grupa (grep {$groups{$_}>10} keys %groups) {
        my ($p,$r) = f_score($koncovka, $grupa);

        print $koncovka."\t".$grupa."\t".$p."\t".$r;
        print "\n";
    }
}

