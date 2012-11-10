use strict;
use warnings;

use 5.010;
say "start";

system "rm -r data/webcol_pred_perc data/webcol_za_perc";
mkdir "data/webcol_pred_perc";
mkdir "data/webcol_za_perc";

use 5.010;
sub doIt {
    my ($regular, $perc) = @_;

    for my $fname (<$regular/*>) {
        open my $f, "<:utf8", $fname or die $!;
        
        my %words;
        my $count;
        while (my $word = <$f>) {
            chomp($word);
            $words{$word}++;
            $count++;
        }

        close $f;

        my $normo_count;

        if (scalar keys %words > 100 ) {
            my @best = sort {$words{$b} <=> $words{$a}} keys %words;
            @best = @best[0..99];
            for (@best) {
                $normo_count+=$words{$_};
            }    
            my %words_copy;
            @words_copy{@best} = @words{@best};
            %words = %words_copy;
        } else {
            $normo_count = $count;
        }

        my $pfname = $fname;
        $fname =~ s/$regular/$perc/;
        open my $pf, ">:utf8", $fname or die $!;
        for my $word (sort {$words{$b} <=> $words{$a}} keys %words) {
            my $wordcount = $words{$word};
            my $perc = int((1000*$wordcount)/$normo_count);
            say $pf $perc."\t".$word;
        }
        close $pf;
    }
}

doIt("data/webcol_pred", "data/webcol_pred_perc");
doIt("data/webcol_za", "data/webcol_za_perc");
