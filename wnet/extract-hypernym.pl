#!/usr/bin/perl

use WordNet::QueryData;

# Input: <input file> contains words separeted by a line
# Output: <output file> contains words separated by a line
#   and extracted from Wordnet database

my $wn = WordNet::QueryData->new;

# ----------------------------
# Open file
# ----------------------------

open(FILE1, $ARGV[0]) or die "Canot open the file !!!";
open(FILE2, ">$ARGV[1]");

@line = <FILE1>;

my @senses;

foreach my $term (@line){

    chomp($term);
    my @temp = $wn->querySense("$term#n#1", "hype");
    if (scalar @temp > 0){
	push @senses, @temp;
    }
    else{
	push @senses, $term;
    }
	
}

foreach my $i (@senses){
    my @temp = split("#", $i);
    print FILE2 @temp[0], "\n";
}

close(FILE2);
close(FILE1);
