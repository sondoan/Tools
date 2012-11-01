#!/usr/bin/perl

# Normalize string
# Convert all case into normal

# Input: <input file>. File <input> duoc sort theo thu tu tu dien
# Output: <output file>


open(FILE1, $ARGV[0]);
open(FILE2, ">$ARGV[1]");

@arry=<FILE1>;

$length = @arry;
my @vocab;

foreach $term(@arry){
    chomp($term);    
    $term =~ tr/[A-Z]/[a-z]/;
    push @vocab, $term;
}

my $i=0;
while ($i < $length){
    if ($vocab[$i] eq $vocab[$i+1]){
	$i++;
    }
    else {
	print FILE2 $vocab[$i], "\n";	
	$i++;
    }
#    $i++;
}

close(FILE2);
close(FILE1);

