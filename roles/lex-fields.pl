
use strict ;

our ($dbg_scf_code, $dbg_scf_label, $dbg_v) ;

sub split_top_paren
{ # split_top_paren
  my ($arg, $parts) = @_ ;

  my ($ind, $chr, $paren, $p) ;
  
  # remove outer brackets

  $arg =~ s/^\(// ;
  $arg =~ s/\($// ;

  # change parenthesis to a string because it may confuse
  # bracket-balancing later

  $arg =~ s/\|\(\| \(/|-LRB-| -LRB-/g ;
  $arg =~ s/\|\)\| \)/|-RRB-| -RRB-/g ;

  $arg =~ s/\(\|([^\|]*)\(([^\|]*)\|/(|\1-LRB-\2|/g ;
  $arg =~ s/\(\|([^\|]*)\)([^\|]*)\|/(|\1-RRB-\2|/g ;

  # repeat in case there are several parenthesis between | |

  $arg =~ s/\(\|([^\|]*)\(([^\|]*)\|/(|\1-LRB-\2|/g ;
  $arg =~ s/\(\|([^\|]*)\)([^\|]*)\|/(|\1-RRB-\2|/g ;

  $arg =~ s/\(\|([^\|]*)\(([^\|]*)\|/(|\1-LRB-\2|/g ;
  $arg =~ s/\(\|([^\|]*)\)([^\|]*)\|/(|\1-RRB-\2|/g ;

  @{$parts} = () ;

  $p = '' ;
  $paren = 0 ;

  for ($ind = 0; $ind < length($arg); $ind++)
  {

    $chr = substr($arg, $ind, 1) ;

    if (($paren > 0) || ($chr eq '('))
    {
      $p .= $chr ;
    }
    
    if ($chr eq ')')
    {
      $paren-- ;
      if ($paren == 0)
      {
	push @{$parts}, $p ;
	$p = '' ;
	next ;
      }
    }
    
    if ($chr eq '(')
    {
      $paren++ ;
    }
  }

  # restore the parenthesis

  foreach $p (@{$parts})
  {
    $p =~ s/-LRB-/(/g ;
    $p =~ s/-RRB-/)/g ;
  }

} # split_top_paren

sub get_words_tags
{ # get_words_tags

  # type: words, tags, pp

  my ($info, $type, $words, $tags) = @_ ;

  my ($p, $w, $t, @arg_parts, @entries) ;

  # delete the dot at the end of lists

  $info =~ s/\s\.\s/ /g ;

  # printf "get_words_tags: type '%s'\n%s...\n", $type,  substr($info, 0, 70) ;

  @{$words} = () ;
  @{$tags} = () ;

  # If this is a PP argument, test it is in the format we expect:
  # (PSUBCAT ...) (preposition list) (argument list)

  split_top_paren($info, \@arg_parts) ;

  if (($info =~ /\(PSUBCAT [A-Za-z]+/)
      &&
      (scalar @arg_parts != 3))
  {
    printf "Unexpected structure of the PP argument, ".
      "%d parts: v=%s scf %d %s\ninfo=%s...\n",
	scalar @arg_parts, $dbg_v, $dbg_scf_code, $dbg_scf_label,
	substr($info, 0, 70) ;
    # printf "  1: %s \n", $arg_parts[0] ;
    # printf "  2: %s \n", $arg_parts[1] ;
    # printf "  3: %s \n", $arg_parts[2] ;
    # printf "  4: %s \n", $arg_parts[3] ;

    # use only the first three parts
    # return ;
  }

  if ($type eq 'PP')
  {
    # get the list of prepositions of a PP argument

    $info = $arg_parts[1] ;
    # printf "info=%s\n", $info ;

    # the list is in a deeper parenthesis level

    split_top_paren($info, \@arg_parts) ;
    $info = $arg_parts[0] ;

    # split_top_paren($info, \@arg_parts) ;
    # $info = $arg_parts[0] ;

    # printf "Prep=%s\n", $info ;
    # remove | | and parenthesis

    $info =~ s/[\|\(\)]//g ;

    # get the prepositions

    @{$words} = split (/\s+/, $info) ;
    pop @{$words} ;

    # printf "%d prepositions\n", scalar @{$words} ;
    return ;
  }

  # get (|word| tag) pairs

  if ($info =~ /\(PSUBCAT [A-Za-z]+/)
  {
    # in PP argument, the 2nd part contains the list of NP heads
    $info = $arg_parts[2] ;
  }

  split_top_paren($info, \@entries) ;

  # printf "Entries: %s...\n", join(', ', @entries[0..2]) ;

  foreach $p (@entries)
  {

    # printf "entry '%s'\n", $p ;

    # handling internal structure such as:
    #   ((|Hugh| NP1) (|Despenser| NP1) (|Berwyk| NP1))
    # be retaining the first component

    if ($p =~ /\)\s+\(/)
    {
      # this entry has an internal structure
      split_top_paren($p, \@arg_parts) ;
      $p = $arg_parts[0] ;
      # printf "   sub-entry '%s'\n", $p ;
    }

    $p =~ s/[\|\(\)]//g ;
    ($w, $t) = split (/\s+/, $p) ;

    if (! defined $t)
    {
      # empty word, skip
      next ;
    }

    push @{$words}, $w ;
    push @{$tags}, $t ;

  }

  # printf "%d words %d tags\n", scalar @{$words}, scalar @{$tags} ;
} # get_words_tags

sub scf_fields
{
  my ($line, $fields) = @_ ;

  my ($f, @field_data, $fname, @words, @tags, @preps, $w) ;
  
  $line =~ s/\s\s+/ / ;

  @field_data = ($line =~ /(:[^:]*)/g) ;
  %{$fields} = () ;

  foreach $f (@field_data)
  {
    ($fname) = ($f =~ /^:([^\s]+) /) ;
    $f =~ s/^:([^\s]+) // ;
    $f =~ s/^\s+// ;
    $f =~ s/\s+$// ;
    ${$fields}{$fname} = $f ;
    # printf "%s : %s...\n", $fname, substr($f, 0, 20) ;
  }

  ${$fields}{'TARGET'} =~ tr/A-Z/a-z/ ;

  # printf "'%s'\n", ${$fields}{'TARGET'} ;

  # extract the actual words from the subject and arguments

  foreach $fname (keys %{$fields})
  {
    if ($fname =~ /^[SO]LT/)
    {
      $f = ${$fields}{$fname} ;
    
      # get the subject and arguments
      
      get_words_tags($f, 'words-tags', \@words, \@tags) ;

      # ${$fields}{$fname} = $words[$#words] ;
      # printf "%s: '%s'\n", $fname, ${$fields}{$fname} ;

      ${$fields}{$fname} = [ @words ] ;

      if (scalar @words <= 1)
      {
	${$fields}{$fname} = $words[$#words] ;
      }
      # printf "%s: '%s'\n", $fname, ${$fields}{$fname} ;

      # gor prepositional phrases - get the prepositions
	
      if ($f =~ /\(PSUBCAT/)
      {
	# printf "$fname.prep %s\n", $f ;
	get_words_tags($f, 'PP', \@preps, \@tags) ;

	if (scalar @preps > 0)
	{
	  ${$fields}{$fname.'.prep'} = $preps[$#preps] ;
	  # printf "$fname.prep=%s\n", $preps[$#preps] ;
	}
      }
    }

    if ((${$fields}{$fname} eq 'NIL')
	||
	(${$fields}{$fname} eq ''))
    {
      delete ${$fields}{$fname} ;
    }
  }
}

# main

return(1) ;
