#!/usr/bin/perl

# Change element names: target->pred
#                       tag->pos
#

use XML::DOM ;
use XML::DOM::XPath;

use English ;
use strict ;
use Getopt::Std ;

require Encode;

my ($proc_dir) ;

$proc_dir = $PROGRAM_NAME ;
$proc_dir =~ s/\/[-_.\w]+$// ;
push @INC, $proc_dir ;

my (%loaded_lexicons) ;

sub compare_val_cond
{ # compare_val_cond

  my ($val, $cond) = @_ ;

  # test whether it is a direct comparison
  # or a regular expression ('/ ... /')

  if (($cond =~ /^\//) && ($cond =~ /\/$/))
  {
    $cond =~ s/^\/// ;
    $cond =~ s/\/$// ;

    # printf OUT "Condition '%s' '%s'\n", $head_word, $cond ;
    return (($val =~ /$cond/)) ;
  }
  else
  {
    return (($val eq $cond)) ;
  }
  
} # compare_val_cond

sub test_predicate
{ # test_predicate

  # test a condition on the verb iteslf

  my ($sc, $text_elem, $cond) = @_ ;

  my ($verb_tok_id, $text_cond, $match) ;
  my ($verb_tok, @cond_attrs, $att_node, $cond_att, $verb_att) ;

  $verb_tok_id = $sc->getElementsByTagName('target')->getAttribute('id') ;

  # get the verb token

  ($verb_tok) = $text_elem->findnodes("./tokens/tok[\@id='$verb_tok_id']") ;

  @cond_attrs = $cond->getAttributes->getValues ;

  foreach $att_node (@cond_attrs)
  {
    if ($att_node->getName eq 'slot')
    {
      # the slot name, not relevant here
      next ;
    }

    $verb_att = $verb_tok->getAttribute($att_node->getName) ;

    if (! defined ($verb_att))
    {
      return(0) ;
    }

    # the condition on the attribute (typically 'pos')

    $cond_att = $att_node->getValue ;

    return (compare_val_cond ($verb_att, $cond_att)) ;

  }

} # test_predicate

sub test_condition
{ # test_condition
  my ($sc, $text_elem, $cond) = @_ ;

  my ($slot, $text_cond, $empty_result, $match) ;
  my ($slot_elem, $head_word, $tok_id, $pos_tag) ;

  $slot = $cond->getAttribute('slot') ;

  if ($slot eq 'pred')
  {
    return (test_predicate($sc, $text_elem, $cond)) ;
  }

  $text_cond = $cond->getAttribute('text') ;

  if (! defined $text_cond)
  {
    # for now only a textual condition is implemented
    return (1) ;
  }

  # printf OUT "slot='%s'\n", $slot ;

  ($slot_elem) = $sc->findnodes("./slot[\@name='$slot']") ;

  # the conditioned slot does not exist in this sentence
  # - act according to the 'empty' attribute.
  # Return false by default


  if (! defined $slot_elem)
  {
    $empty_result = $cond->getAttribute('empty') ;

    if ((defined $empty_result) && ($empty_result eq 'true'))
    {
      return (1) ;
    }
    return(0) ;
  }

  $head_word = $slot_elem->getFirstChild->getData ;

  # printf OUT "head='%s'\n", $head_word ;

  return (compare_val_cond ($head_word, $text_cond)) ;

} # test_condition

sub get_words
{ # get_words

   my ($tokens_elem, $from_tok, $to_tok) = @_ ;

   my ($tok, $cur_id, $w, $words) ;

   ($tok) = $tokens_elem->findnodes(".//tok[\@id='$from_tok']") ;

   # printf OUT "from=%s\n", $from_tok ;

   $cur_id = $from_tok ;
   $words = $tok->getFirstChild->getData ;

   while ($cur_id ne $to_tok)
   {
     $tok = $tok->getNextSibling ;
     if ($tok->getNodeTypeName ne 'ELEMENT_NODE')
     {
       next ;
     }
     $cur_id = $tok->getAttribute('id') ;
     $words .= ' '.$tok->getFirstChild->getData ;
   }

   return ($words) ;

} # get_words

sub expand_tok
{ # expand_tok

  my ($tok_id, $text_elem, $from_tok, $to_tok, $words) = @_ ;

  my (%rel_info) = ('ncmod', {'-', 1, '+', 1},
		   'detmod', {'-', 1, '+', 1},
		   'xmod', {'-', 1, '+', 1},
		   'cmod', {'-', 1, '+', 1},
		   'pmod', {'-', 1, '+', 1},
		   'conj', {'-', 1, '+', 1},
		   ) ;

  my ($tok, $tok_pos, @gr_tok, $gr, $gr_type, $tok_id_n, $sent_id) ;
  my (@args, $arg, $arg_id, $arg_id_n, $from_id_n, $to_id_n) ;

  ($tok) = $text_elem->findnodes(".//tok[\@id='$tok_id']") ;

  # printf OUT "Expand id=%s\n", $tok_id ;

  $tok_pos = $tok->getAttribute('tag') ;

  # default, use just the current token

  ${$from_tok} = $tok_id ;
  ${$to_tok} = $tok_id ;

  # expand only nouns
  
  if ($tok_pos !~ /^N/)
  {
    ${$words} = get_words($text_elem, $tok_id, $tok_id) ;
    return ;
  }

  # remove the sentence number from the token ID

  ($tok_id_n) = ($tok_id =~ /(\d+)$/) ;
  $sent_id = $tok_id ;
  $sent_id =~ s/\.$tok_id_n$// ;

  $from_id_n = $tok_id_n ;
  $to_id_n = $tok_id_n ;
  
  @gr_tok = $text_elem->findnodes(".//gr[./arg[\@id='$tok_id']]") ;

  foreach $gr (@gr_tok)
  {
    $gr_type = $gr->getAttribute("rel") ;

    # consider only certain relations

    if (! exists $rel_info{$gr_type})
    {
      next ;
    }

    @args = $gr->findnodes("./arg[\@id]") ;

    foreach $arg (@args)
    {
      $arg_id = $arg->getAttribute("id") ;
      ($arg_id_n) = ($arg_id =~ /(\d+)$/) ;

      if (exists $rel_info{$gr_type}{'-'}
	  &&
	  ($arg_id_n < $from_id_n))
      {
	$from_id_n = $arg_id_n ;
      }

      if (exists $rel_info{$gr_type}{'+'}
	  &&
	  ($arg_id_n > $to_id_n))
      {
	$to_id_n = $arg_id_n ;
      }
    }
  }

  ${$from_tok} = $sent_id.'.'.$from_id_n ;
  ${$to_tok} = $sent_id.'.'.$to_id_n ;

  ${$words} = get_words($text_elem, ${$from_tok}, ${$to_tok}) ;

} # expand_tok

sub map_scf_roleset
{ # map_scf_roleset

  my ($sc, $text_elem, $mapping, $rs) = @_ ;

  my ($rel, @rel_args, $a, @attrs, $att) ;
  my ($map, $arg, $slot, $role, $str) ;
  my ($slot_elem, $head_word, $phrase, $tok_id, $from_tok, $to_tok) ;
  my (@slot_toks, $s, @ids, @arg_toks, @ph, $t, %p) ;

  # print the role set and its attribute
  # (currently its name and sense)

  printf OUT " <roleset" ;
  @attrs = $rs->getAttributes->getValues ;

  foreach $att (@attrs)
  {
    printf OUT " %s='%s'", $att->getName, $att->getValue ;
  }

  printf OUT " scf_id='%s'", $sc->getAttribute('id') ;
  print OUT ">\n" ;

  foreach $map ($mapping->getElementsByTagName('map'))
  { # loop on the slots to map

    $slot = $map->getAttribute('slot') ;
    $arg = $map->getAttribute('arg') ;
    $role = $map->getAttribute('role') ;

    if ((! defined $arg) || (! defined $slot))
    {
      $str = $rs->toString ;
      die "Argument or slot missing:\n$str\n" ;
      exit(1) ;
    }

    # the slot specification may contain several slots
    # or other tokens, for example for SCF 147 the text
    # which is mapped to Arg1 is 'OLT1L as OLT2'
    # (e.g. confirm outbreak as H5N1") .

    @slot_toks = split(/\s+/, $slot) ;
    @arg_toks = () ;
    @ids = () ;
    
    foreach $s (@slot_toks)
    {
      if (($s eq 'SLTL') || ($s =~ /^OLT.L/))
      {
	
	($slot_elem) = $sc->findnodes("./slot[\@name='$s']") ;

	if (! defined $slot_elem)
	{
	  next ;
	}

	$head_word = $slot_elem->getFirstChild->getData ;
	$tok_id = $slot_elem->getAttribute('id') ;

	@ph = () ;

	foreach $t (split(/,/, $tok_id))
	{
	  expand_tok($t, $text_elem,
		     \$from_tok, \$to_tok, \$phrase) ;
	  push @ph, $phrase ;
	}

	if (scalar @ph == 1)
	{
	  $phrase = $ph[0] ;
	}
	else
	{
	  foreach $phrase (@ph)
	  {
	    $p{$phrase} = 1 ;
	  }

	  if (scalar keys %p == 1)
	  {
	    $phrase = $ph[0] ;
	  }
	  else
	  {
	    $phrase = '('.join(' OR ', sort keys %p).')' ;
	  }
	}
	
	push @arg_toks, $phrase ;
	push @ids, $tok_id ;
      }
      else
      {
	push @arg_toks, $s ;
      }
    }

    if (scalar @arg_toks > 0)
    {
      printf OUT "  <role role='%s' tok='%s'>%s</role>\n",
	$role, join(',', @ids), join(' ', @arg_toks) ;
    }

  } # loop on mappings

  print OUT " </roleset>\n" ;

} # map_scf_roleset

# main

my ($in, $out, $scf_pr_map_file) ;

my ($parser, $sent, $node, $text_elem, $rels_elem, $tokens_elem) ;
my ($lex, $scf_code, $scf_label, $verb, $target) ;
my (@toks, $t, $id, $word, $tag) ;
my (@scf_elems, $sc, @conditions, $cond, $match, @scf_slots) ;
my ($match_mode, @role_sets, $rs, $rs_num, @mappings, $mapping, $i_map) ;

my ($map_top_elem, $scf_map, $arg_map) ;
my ($tmp_in_file) = "/tmp/$$.in" ;
my ($tmp_out_file) = "/tmp/$$.out" ;

our ($opt_i, $opt_o, $opt_m) ;

$parser= XML::DOM::Parser->new();

getopts("i:o:m:") ;

$in = $opt_i ;
$out = $opt_o ;
$scf_pr_map_file = $opt_m || 'map.xml' ;

$map_top_elem = $parser->parsefile ($scf_pr_map_file);

open (IN, "<$in") ;
open (OUT, ">$out") ;

undef $sent ;

while (<IN>)
{
  #
  # Assuming that <text> and </text> appear
  # without other information in the same line
  #

  if (/^<text/)
  {
    $sent = $_ ;
    # debug
    # print ;
    printf OUT ;
    next ;
  }

  if (! defined $sent)
  {
    next ;
  }

  $sent .= $_ ;

  if (! /^<\/text>/)
  {
    printf OUT ;
    next ;
  }

  $sent = Encode::encode_utf8($sent) ;

  # the text may be composed of several sentences.
  # There is a separate set of token IDs for each
  # of the sentences.

  # printf "sentence $sent\n" ;
  
  $text_elem = $parser->parse ($sent);

  ($rels_elem) = $text_elem->getElementsByTagName('rels') ;

  @scf_elems = $text_elem->getElementsByTagName('scf') ;

  if (scalar @scf_elems == 0)
  {
    goto next_sent ;
  }

  $rs_num = 0 ;

  foreach $sc (@scf_elems)
  {
    $verb = $sc->getAttribute('verb') ;
    $scf_code = $sc->getAttribute('class') ;

    # find a SCF mapping rule by SCF code

    ($scf_map) = $map_top_elem->findnodes(".//verb-map[\@verb='$verb']/scf[\@scf='$scf_code']") ;

    # if no mapping was found by code - search by label
    # Search for the full label or for prefixes of it
    # that map to some of the slots.
    # Prefixes of the labels are matched only if they end with '*'.
    # For example label='PP*' will match all SCFs with PP as the
    # first slot if no exact match was found
    
    if (! defined $scf_map)
    {
      # if no mapping was found by code - search by label

      $scf_label = $sc->getAttribute('label') ;
      ($scf_map) = $map_top_elem->findnodes(".//verb-map[\@verb='$verb']/scf[\@label='$scf_label']") ;

      if (! defined $scf_map)
      {
	@scf_slots = split(/_/, $scf_label) ;
	pop @scf_slots ;
	while ((scalar @scf_slots > 0) && (! defined $scf_map))
	{
	  $scf_label = join('_', @scf_slots) ;
	  ($scf_map) =
	    $map_top_elem->findnodes(".//verb-map[\@verb='$verb']/scf[\@label='$scf_label\*']") ;
	  pop @scf_slots ;
	}
      }

      
    }

    if (! defined $scf_map)
    {
      # printf STDERR "No map data for verb '%s' SCF %d\n", $verb, $scf_code ;
      # next ;
 
      ($scf_map) = $map_top_elem->findnodes(".//verb-map[\@verb='$verb']/scf[\@scf='*' and \@label='default']") ;

      if (! defined $scf_map)
      {
	# printf STDERR "No map data for verb '%s' SCF %d\n", $verb, $scf_code ;
	next ;
      }

      # printf STDERR "Default map data used for verb '%s' SCF %d\n", $verb, $scf_code ;
    }

    $match_mode = $scf_map->getAttribute('match') || 'first' ;

    @role_sets = $scf_map->getElementsByTagName('roleset') ;

    foreach $rs (@role_sets)
    {

      $match_mode = $rs->getAttribute('match') || $match_mode ;

      # test of the role set contains a condition

      @mappings = $rs->getElementsByTagName('mapping') ;

      foreach $i_map (0 .. $#mappings)
      {
	$mapping = $mappings[$i_map] ;
	
	@conditions = $mapping->getElementsByTagName('cond') ;
	$match = 1 ;

	foreach $cond (@conditions)
	{
	  $match = test_condition ($sc, $text_elem, $cond) ;

	  # printf OUT "match=%d\n", $match ;
	  if (! $match)
	  {
	    last ;
	  }
	}
	
	if (($i_map == 0) && $match
	    && ($match_mode eq 'first'))
	{
	  last ;
	}
      }

      if (! $match)
      {
	next ;
      }

      $rs_num++ ;

      if ($rs_num == 1)
      {
	printf OUT "<roles>\n" ;
      }

      map_scf_roleset ($sc, $text_elem, $mapping, $rs) ;
    }

  }

  if ($rs_num > 0)
  {
    printf OUT "</roles>\n" ;
  }

  
 next_sent:;
  
  printf OUT "</text>\n" ;
    
  $text_elem->dispose ;
  undef $sent ;
  next ;
}

close IN ;
close OUT ;
