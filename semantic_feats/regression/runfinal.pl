use strict;
use warnings;
use forks;

use 5.010;


my $featuretype=$ARGV[0];

#my @rozumne  = qw(P);
my @rozumne  = qw(A C R K V H Z M P N F D);

sub run {
    my ($cat) = @_;


    system("octave spustOneCatAll.m $cat $featuretype >/dev/null 2>/dev/null");
#    system("octave spustOneCatAll.m $cat $featuretype >/dev/null 2>/dev/null");
    #system("octave spustOneCat.m $lambda");
   
    my $resfile = "../results/ML_results_".$featuretype."_".$cat;
    
    if (!-e $resfile) {
        say "SHITT";
        say "didnt finish $resfile";
        die "didnt finish";
    }
    my $f = `tail -1 $resfile`;
    
    $f=~s/^\s+//;
    $f=~s/\s+$//;
    my @counts = split(/\s+/, $f);
    my %res;
    @res{qw(TP FP FN TN)} = @counts;
    

    system("rm $resfile");
    return %res;
}

sub saywithtime {
    my $w = shift;
    my $lt = localtime;
    say $lt, " : ",$w;
}

my %mythreads;

for my $category (@rozumne) {
    saywithtime "STARTIN category". $category;

        my $shit=localtime;
        
        my $mythread = threads->create(
            {context=>'list'}, 
            sub{return run($category)}
        );
        $mythreads{$category} = $mythread;
}
my $sum_prec;
my $sum_recl;
my $total_TP;
my $total_FP;
my $total_FN;

my %rz;

for my $category (@rozumne) {
        my %res = $mythreads{$category}->join();
        $total_TP+=$res{TP};
        $total_FP+=$res{FP};
        $total_FN+=$res{FN};
        $rz{$category}=0;
        if (($res{TP}+$res{FP})!=0) {
            my $prec = $res{TP}/($res{TP}+$res{FP});
            my $recl = $res{TP}/($res{TP}+$res{FN});
            my $fs = ($prec+$recl==0) ? 0 : 2*$prec*$recl/($prec+$recl);
            $rz{$category}=$fs;
            $sum_prec+=$prec;
            $sum_recl+=$recl;
        }
}

my $avrg_prec = $sum_prec/scalar @rozumne;
my $avrg_recl = $sum_recl/scalar @rozumne;
my $avrg_Fscore = 2*$avrg_prec*$avrg_recl/($avrg_prec+$avrg_recl);
my $total_prec = $total_TP/($total_TP+$total_FP);
my $total_recl = $total_TP/($total_TP+$total_FN);
my $total_Fscore = 2*$total_prec*$total_recl/($total_prec+$total_recl);

open my $finalresf, ">", "../results/ML_final_".$featuretype;
say $finalresf $total_prec;
say $finalresf $total_recl;
say $finalresf $total_Fscore;
say $finalresf $avrg_prec;
say $finalresf $avrg_recl;
say $finalresf $avrg_Fscore;

for (@rozumne) {
    say $finalresf $_."\t".$rz{$_};
}
