#!/usr/bin/perl
use utf8;
use Encode;
$CodeL = 4; #length of character code
for my $argv (@ARGV){
    open my $fh, "<", $argv or die "$argv : $!";
    while(<$fh>){
	my @chel = split(//,$_);
	while((my $chara = shift(@chel)) ne ''){
	    if($chara eq '\\'){
		if(($chara = shift (@chel)) eq 'u'){
		    #take utf-8 (hex) code and convert
		    my @ccode = ();
		    for ($i = 0; $i < $CodeL; $i++){
			push (@ccode, shift(@chel));
		    }
		    print &outchara(join('',@ccode));
		}#end of '\u' process
	    }else{#end of '\' is found 
		print $chara;
	    }
	}#end of while loop  ($chara)
    }#end of one line <$fh>
    print "\n";
}#end of process for input files

sub outchara{
    my $inc = @_[0];
    my $in = hex($inc);
    my $alpha = chr($in);
    return Encode::encode("utf8", $alpha); # UTF8
}

