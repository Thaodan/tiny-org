#!/usr/bin/env perl
use Term::ANSIColor;
sub file_to_array($) {
    my $file = shift();
    my ( $filestream, $string );
    my @rray;

    open( $filestream, $file ) or die("cant open $file: $!");
    while ( $string = <$filestream> ) {
        push( @rray, $string );
    }
    close($filestream);
    return @rray;
}
my %colors = (
	      light_blue => 'ansi12'
	      );
my %conf = (
	      head => [ 'green', $colors{light_blue}],
	      note => {TODO =>'red',
			DONE => 'green'
		      }
	     );

sub note
{
   my $state = shift();
   my $note = shift();
   my $color = $conf{note}{$state};
   $note = $state if not $note ;
   print color "bold  $color";
   print $note;
   print color 'reset';
}
sub bold
{
   my $word = shift();
   print color 'bold';
   print $word;
   print color 'faint';
}
sub italic
{
   my $word = shift();
   print color 'italic';
   print $word;
   print color 'faint';
}
sub o_link
{
   my $word = shift();
   my $name;
   $word =~ s/^\[\[//;
   $word =~ s/\]\]$//;
   if ( $word =~ /.*\]\[.*/)
   {
      $name = $word;
      $name =~ s/.*\]\[//;
      $word =~ s/\]\[.*//;
   }
   if ( $name )
   {
      italic("$name ($word)");
   }
   else
   {
      italic  $word;
   }
}
sub head($)
{
   my $head = shift(); # head string
   # my $level = shift(); # which level is our head
   my $level = () = $head =~ /\*/gi;
   my $aste_str_regex; # * str for regex
   my $aste_str;
   # count how many * we got
   for (my $tmp_level=$level;$tmp_level != 0;$tmp_level--)
   {
      $aste_str_regex="$aste_str_regex\\*";
      $aste_str="$aste_str*";
   }
   
   print color  $conf{head}[$level-1];
   print $aste_str, ' ';
   # TODO: add support for done
   for my $state ( 'TODO' , 'DONE' )
   {
      if ( $head =~ /$aste_str_regex\ $state*/ ) # do we got TODO
      {
	 note($state);
	 $head =~ s/$aste_str_regex\ $state//;
	 $head =~ s/$aste_str_regex\ //;
	 print ' ';
      }  
   }

   print color $conf{head}[$level-1];
   # print "$head\n";
   $head =~ s/$aste_str_regex//; # remove asterics before giving them to line
   line($head);
   print color 'reset';
}

# print in current color and check for bold or italic
sub line
{
   my $line_raw = shift();
   $line_raw =~ s/^\ //; # cut white space in from of arg
   my @line = split( /\s/, $line_raw);
   for my $word( @line )
   {
      # check if we got format sigs

      if ( $word =~ /^\**\*/ )
      {
	 bold($word);
      }
      if ( $word =~ /^\/*\//)
      {
	 italic($word);
      }
      if ( $word =~ /^\[\[.*\]\]/)
      {
	 o_link($word);
      }
      # or if we are just a word
      else
      {
	print $word;
      }
      print ' '; # add space til next word
   }
}
my $input_file_raw = $ARGV[0];
my @input_file = file_to_array($input_file_raw);
for my $line ( @input_file )
{
   if (  $line =~ /^#/)
   {

   }
   else
   {
      if ( $line =~ /\*{1,}\ / )
      {
	 head($line);
      }
      else
      {
	 line($line);
      }
      print color 'reset';
      print "\n";
   }
}
