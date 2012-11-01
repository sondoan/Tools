#!/usr/bin/perl

use XML::DOM ;
# use XML::DOM::XPath;

use English ;
use strict ;

require Encode;

my ($proc_dir) ;

$proc_dir = $PROGRAM_NAME ;
$proc_dir =~ s/\/[-_.\w]+$// ; 
push @INC, $proc_dir ;

require 'lex-fields.pl' ;

my ($in, $out) ;
my ($tag_script_file) = "/tmp/$$.tag.sh" ;
my ($gr_script_file) = "/tmp/$$.gr.sh" ;
my ($lex_script_file) = "/tmp/$$.lex.sh" ;

#my ($rasp_dir) = '/export/home/common/software/rasp1' ;
my ($rasp_dir) = '/export/home/scratch2/rasp_parser/rasp1' ;

sub find_ids
{
  my ($toks, $word) = @_ ;

  my ($i, @ids) ;

  foreach $i (0 .. $#{$toks})
  {
    if (${$toks}[$i]{'word'} eq $word)
    {
      push @ids, ${$toks}[$i]{'id'} ;
    }
  }

  return @ids ;
}

sub create_script
{ # create_script

  my ($tag_script_file, $gr_script_file, $lex_script_file) = @_ ;

  open (SCR_TAG, ">$tag_script_file") ;

  print SCR_TAG <<EOT
#!/bin/sh

in=\$1
out=\$2

$rasp_dir/scripts/run-tag.sh < \$in > \$out 2> /dev/null

EOT
;

  close SCR_TAG ;

  system ("chmod +x $tag_script_file") ;

  open (SCR_GR, ">$gr_script_file") ;

  print SCR_GR <<EOT
#!/bin/sh

in=\$1
out=\$2

$rasp_dir/scripts/runprob.sh -og < \$in > \$out 2> /dev/null

EOT
;

  close SCR_GR ;

  system ("chmod +x $gr_script_file") ;

  open (SCR_LEX, ">$lex_script_file") ;

  print SCR_LEX <<EOT
#!/bin/sh

in=\$1
out=\$2

sep9_dir=$rasp_dir/subcat

$rasp_dir/scripts/runprob.sh -op < \$in | $rasp_dir/scripts/newpreprocesspatts.pl - > \$in.psets

/bin/rm -f \$in.lex

touch \$in.lex

l=`cat \$in.psets | wc -l`

# process each pattern set individually
# so that each lexicon entry will contain a single occurence

for ((i=1; i <= \$l; i++)); do

  head -\$i \$in.psets | tail -1 > \$in.psets.tmp

#  /export/home/common/software/rasp1/gde/ix86_linux/gde -q -batch <<EOF
  /export/home/scratch2/rasp_parser/rasp1/gde/ix86_linux/gde -q -batch <<EOF
!(lisp-top-loop)
(load "\$sep9_dir/sep9.lsp")
(construct-lexicon "\$in.psets.tmp" "\$in.lex.tmp" 1 t t)
EOF

  cat \$in.lex.tmp >> \$in.lex
done

/bin/rm -f \$out

# debug
# cat \$in.psets >>  \$out

/bin/rm \$in.psets ;

cat \$in.lex >> \$out
echo -e '\\n' >> \$out

EOT
;

  close SCR_LEX ;

  system ("chmod +x $lex_script_file") ;

} # create_script

sub process_lex
{ # process_lex

  my ($sent_id, $toks) = @_ ;
  
  my (%fields, $fname, $scf_id, $tok_id) ;
  my ($lex, $scf_code, $scf_label, $target, $verb) ;
  
  printf OUT "<lex id='%s'>\n", $sent_id ;
  $scf_id = 0 ;

  while (<TMP_LEX_OUT>)
  {
    chop ;
    
    if (/EPATTERN/)
    {
      # a new lexicon entry
      $lex = $_ ;
      next ;
    }

    $lex .= $_ ;

    if (/:LRL/)
    {
      # the end of a lexicon entry
      
      scf_fields ($lex, \%fields) ;

      ($scf_code) = ($fields{'CLASSES'} =~ /\((\d+) /) ;
      ($scf_label) = ($fields{'SUBCAT'} =~ /\(VSUBCAT ([^\)]+)\)/) ;
      ($verb) = ($fields{'TARGET'} =~ /\|([a-z]+)/) ;
      ($target) = ($fields{'TARGET'} =~ /\|([^\|]+)/) ;

      $scf_id++ ;
	
      printf OUT "<scf id='%d' verb='%s' class='%s' label='%s'>\n",
	$scf_id, $verb, $scf_code, $scf_label ;

      printf OUT " <target id='%s'>%s</target>\n",
	join (',', (find_ids($toks, $target))), $target ;

      $fname = 'SLTL' ;
	
      if (exists $fields{$fname})
      {
	if ((ref $fields{$fname}) =~ /ARRAY/)
	{
	  # take the last word if the argument
	  # is multiword
	  $fields{$fname} = $fields{$fname}[$#{$fields{$fname}}] ;
	}
	printf OUT " <slot name='%s' id='%s'>%s</slot>\n",
	  $fname, join (',', (find_ids($toks, $fields{$fname}))),
	    $fields{$fname} ;
	  
      }

      foreach $fname (keys %fields)
      {
	if ($fname =~ /^OLT/)
	{
	  if ((ref $fields{$fname}) =~ /ARRAY/)
	  {
	    # take the last word if the argument
	    # is multiword
	    $fields{$fname} = $fields{$fname}[$#{$fields{$fname}}] ;
	  }
	  printf OUT " <slot name='%s' id='%s'>%s</slot>\n",
	    $fname, join (',', (find_ids($toks, $fields{$fname}))),
	      $fields{$fname} ;
	}
      }
	
      print OUT "</scf>\n" ;

    }
  }

  printf OUT "</lex>\n" ;

} # process_lex

# main

my ($parser, $text_data, $n_sent, $sent_num) ;
my ($node, $text_elem, @raw_nodes, $tagged) ;
my ($raw_text, $scf_id, $text_id, $sent_id, $gr_id, $tok_id) ;
my (@toks, @toks_o, $t, $id, $word, $tag, $rel, @rel_args, $a) ;

my ($tmp_raw_in_file) = "/tmp/$$.in" ;
my ($tmp_tag_out_file) = "/tmp/$$.tag.in" ;
my ($tmp_tagged_in_file) = "/tmp/$$.tagged.in" ;
my ($tmp_gr_out_file) = "/tmp/$$.gr.out" ;
my ($tmp_lex_out_file) = "/tmp/$$.lex.out" ;

$parser= XML::DOM::Parser->new();

($in, $out) = @ARGV ;

create_script($tag_script_file, $gr_script_file, $lex_script_file) ;

open (IN, "<$in") ;
open (OUT, ">$out") ;

undef $text_data ;

while (<IN>)
{
  if (/^<text/)
  {
    $text_data = $_ ;
    ($text_id) = ($text_data =~ /id=.(\d+)/) ;
    $sent_id = $text_id ;
    $n_sent = 0 ;
    printf OUT ;
    next ;
  }

  if (! defined $text_data)
  {
    next ;
  }

  $text_data .= $_ ;

  # assuming that the </text> line does not contain an
  # opening tag for another entry 

  if (/^<\/text>/)
  {
    $text_data = Encode::encode_utf8($text_data) ;

    # printf "Sent='%s'\n", $text_data ;

    $text_elem = $parser->parse ($text_data);

    @raw_nodes = $text_elem->getElementsByTagName('raw') ;

    if (scalar @raw_nodes > 0)
    {
      # take the text from the <raw> element
      $raw_text = $raw_nodes[0]->getFirstChild->getData ;
    }
    else
    {
      # no <raw> element - assume the text is directly
      # accessible in the <sentence> element
      $raw_text = $text_elem->getFirstChild->getFirstChild->getData ;
    }

    $raw_text =~ s/^\s+// ;
    $raw_text =~ s/\s+$// ;

    $raw_text =~ s/\x92/'/g ;
    $raw_text =~ s/\x93/"/g ;
    $raw_text =~ s/\x94/"/g ;

    printf OUT "<raw>\n%s\n</raw>\n", $raw_text ;

    open (TMP_RAW_IN, ">$tmp_raw_in_file") ;
    printf TMP_RAW_IN "%s\n", $raw_text ;
    close TMP_RAW_IN ;

    # tag and split into sentences

    system ("$tag_script_file $tmp_raw_in_file $tmp_tag_out_file > /dev/null") ;
    $sent_num = `wc -l $tmp_tag_out_file` ;

    open (TMP_TAG_OUT, "<$tmp_tag_out_file") ;

    while ($tagged = <TMP_TAG_OUT>)
    { # read tagged sentences

      $n_sent++ ;

      if ($sent_num > 1)
      {
	$sent_id = $text_id.'.'.$n_sent ;
      }
      
      open (TMP_TAGGED_IN, ">$tmp_tagged_in_file") ;
      print TMP_TAGGED_IN $tagged ;
      close TMP_TAGGED_IN ;

      system ("$gr_script_file $tmp_tagged_in_file $tmp_gr_out_file > /dev/null") ;

      open (TMP_GR_OUT, "<$tmp_gr_out_file") ;

      $_ = <TMP_GR_OUT> ; # the tokens

      # Change the '&' to an XML entity to avoid confusion.
      s/\&/&amp;/g ;

      chop ;

      printf OUT "<tokens id='%s'>\n", $sent_id ;

      @toks_o = split ;
      @toks = () ;

      foreach $t (@toks_o)
      {
	if ($t !~ /\|/)
	{
	  last ;
	}
	($word, $tok_id, $tag) = ($t =~ /\|(.*):(\d+)_([^\|]+)\|/) ;
	$tok_id = "$sent_id.$tok_id" ;
	printf OUT " <tok id='%s' tag='%s'>%s</tok>\n",
	  $tok_id, $tag, $word ;
	push @toks, { 'word' => $word, 'tag' => $tag, 'id' => $tok_id } ;
      }

      printf OUT "</tokens>\n", $_ ;

      printf OUT "<rels id='%s'>\n", $sent_id ;

      while (<TMP_GR_OUT>)
      { # reading the GR output

	if (/^\s*$/)
	{
	  # empty line - end of information for a sentence
	  last ;
	}


	if (! /[A-Za-z]/)
	{
	  next ;
	}

	s/^\(// ;
	s/\)$// ;

	($rel, @rel_args) = split ;
	($rel) = ($rel =~ /\|([^\|]+)/) ;

	printf OUT " <gr rel='%s'>\n", $rel ;
      
	foreach $a (@rel_args)
	{
	  $a =~ s/\&/&amp;/g ;

	  ($word, $tok_id, $tag) = ($a =~ /\|(.*):(\d+)_([^\|]+)\|/) ;

	  if (defined $word)
	  {
	    printf OUT "  <arg id='%s.%d' tag='%s'>%s</arg>\n",
	      $sent_id, $tok_id, $tag, $word ;
	  }
	  else
	  {
	    $a =~ s/^\|// ;
	    $a =~ s/\|$// ;
	    printf OUT "  <arg>%s</arg>\n", $a ;
	  }
	}
	printf OUT " </gr>\n" ;
      } # reading the GR output

      printf OUT "</rels>\n" ;

      close TMP_GR_OUT ;

      system ("$lex_script_file $tmp_tagged_in_file $tmp_lex_out_file > /dev/null") ;

      # unlink $tmp_tagged_in_file ;

      open (TMP_LEX_OUT, "<$tmp_lex_out_file") ;

      process_lex($sent_id, \@toks) ;

      close TMP_LEX_OUT ;

      # unlink $tmp_lex_out_file ;
	
      unlink $tmp_raw_in_file ;
    }
	
    printf OUT "</text>\n" ;

    $text_elem->dispose ;
    undef $text_data ;
    next ;
  }
}

close IN ;
close OUT ;



