use strict;
use warnings;

use 5.010;
say "start";
my %dict;

binmode (STDOUT, ":utf8");


open my $slovnik, "<:utf8", "data/ruslan-feats/slovnik.features" or die $!;

say "opened";
while (my $data=<$slovnik>) {
    chomp($data);
    my ($f, $s, undef) = split (/\t+/, $data);
    $dict{$s} = undef;
}

close $slovnik;

print "Done reading.\n";

system "rm -r data/webcol_pred data/webcol_za";
mkdir "data/webcol_pred";
mkdir "data/webcol_za";

open my $webcol, "<:utf8", "data/webcoll/vsechno_utf" or die $!;

my $whole = 9015352;
my $tisicina = int($whole/1000);
my $i=0;

my %pre_words;
my %post_words;

READLN:
while (my $line = <$webcol>) {
    if ($i % $tisicina == 0) {
        say $i / $whole;
    }
    $i++;
    chomp $line;
    my @words = split(/\s+/,$line);
    if (!scalar @words) {
        next READLN;
    }
    for (@words) {s/^([^`_-]*)[`_-].*$/$1/};
    @words = ("BEGIN", @words, "END");
    for my $i (1..$#words-1) {
        use 5.010;
        if (exists $dict{$words[$i]}) {
            my $w = $words[$i];
            my $pre_w = $words[$i-1];
            my $post_w = $words[$i+1];
            push @{$pre_words{$w}}, $pre_w;
            push @{$post_words{$w}}, $post_w;
        }
    }
}

for my $w (keys %pre_words) {
    open my $f, ">:utf8", "data/webcol_pred/$w" or die $!;
    for my $pre_w (@{$pre_words{$w}}) {
        say $f $pre_w;
    }
    close $f;
}

for my $w (keys %post_words) {
    open my $f, ">:utf8", "data/webcol_za/$w" or die $!;
    for my $post_w (@{$post_words{$w}}) {
        say $f $post_w;
    }
    close $f;
}
