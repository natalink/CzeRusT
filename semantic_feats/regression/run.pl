use strict;
use warnings;
use forks;

use 5.010;

my $featuretype=$ARGV[0];

my @lambdas=qw(0 0.03 0.1 0.3 1 3 10 30);
my @tolerances = qw(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9);
my @b_tolerances = qw(0.3 0.4 0.5 0.6);
#my @rozumne  = qw(P);
my @rozumne  = qw(A C R K V H Z M P N F D);

sub run {
    my ($lambda, $cat) = @_;


    system("octave spustOneCat.m $lambda $cat >/dev/null 2>/dev/null");
    #system("octave spustOneCat.m $lambda");
   
    my $lambdafile = "../ML_tables/res".$lambda;
    
    if (!-e $lambdafile) {
        say "SHITT";
        say "didnt finish $lambdafile";
        die "didnt finish";
    }
    my $f = `tail -1 $lambdafile`;
    
    $f=~s/^\s+//;
    $f=~s/\s+$//;
    my @perc = split(/\s+/, $f);
    @perc = map {if ($_ eq "NaN") {0} else {$_}} @perc;
    my %res;
    @res{@tolerances} = @perc;
    

    system("rm $lambdafile");
    return %res;
}

sub saywithtime {
    my $w = shift;
    my $lt = localtime;
    say $lt, " : ",$w;
}

sub porovnejTolerance {
    my $nova = shift;
    my $starsi = shift;
    if ($nova==0.5) {
        return 1;
    }
    if ($starsi==0.5) {
        return 0;
    }
    if ($nova>$starsi) {
        return 1;
    } else {
        return 0;
    }
}

for my $category (@rozumne) {
    my $b_l;
    saywithtime "STARTIN category". $category;
    my $b_t;
    my $best=-999;

    my %mythreads;
    for my $lambda (@lambdas) {
        my $shit=localtime;
        saywithtime "TESTIN: $lambda";
        my $mythread = threads->create(
            {context=>'list'}, 
            sub{return run($lambda, $category)}
        );
        $mythreads{$lambda} = $mythread;
    }

    for my $lambda(@lambdas) {
        my %percs = $mythreads{$lambda}->join();
        for my $tolerance (@b_tolerances) {
            

            my $res = $percs{$tolerance};
            
            say "l $lambda t $tolerance r $res";
            if (!defined $res) {
                say "SHIT";
                say "$lambda - $tolerance";
                die "$lambda - $tolerance"
            }
            if ($res>$best) {
                $b_l=$lambda;
                $b_t=$tolerance;
                $best=$res;
            }
            if ($res==$best) {
                if ($tolerance!=$b_t) {
                    if (porovnejTolerance($tolerance, $b_t)) {
                        $b_l=$lambda;
                        $b_t=$tolerance;
          
                    }
                } else {
                    $b_l = $lambda;
                }
            }
        }
    }
    open my $of, ">", "../results/ML_lambda_".$featuretype."_$category" or die $!;
    say $of $b_l;
    say $of $b_t;
    say $of $best;
    close $of;
}
