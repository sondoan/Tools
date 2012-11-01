#!/usr/bin/perl

use WordNet::QueryData;

# Input: <input file> contains words separeted by a line
# Output: <output file> contains words separated by a line
#   and extracted from Wordnet database

my $wn = WordNet::QueryData->new;

# ----------------------------
# Open file
# ----------------------------

open(FILE1, $ARGV[0]) or die "Canot open the file $ARGV[0] !!!";
open(FILE2, ">$ARGV[1]");

@line = <FILE1>;

my @senses;

foreach my $term (@line){

    chomp($term);
    my @temp = $wn->querySense("$term#n", "syns");
    if (scalar @temp > 0){
	push @senses, @temp;
    }
    else{
	push @senses, $term;

#    @temp = $wn->querySense("$term#n", "syns");
#    push @senses, @temp;
    }
	
}

my @vocab;

foreach my $i (@senses){
    my @temp1 = $wn->querySense($i, "syns");
    push @vocab, @temp1;
}

foreach my $i (@vocab){
    my @t=split("#", $i);
    print $t[0], "\n";
}


close(FILE2);
close(FILE1);
