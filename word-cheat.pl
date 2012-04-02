#!/usr/bin/perl 
#
#  word-cheat.pl
#
#    Written mostly by Austin Murphy
#    Released to the Public Domain
#
#    Find the "best" anagrams for a given list of letters
#
#    Potentially useful for cheating at or learning Scrabble 
#      or other word games
#

use strict;
use warnings;

# Enhanced North American Benchmark Lexicon (ENABLE)
#   a public domain word list
#
my $wordfile = 'enable-UC.txt';
my $dictname = "ENABLE";
my %dict;      # dictionary of valid words


# Scrabble values
my %scrabble_values = (
	A => 1,
	B => 3,
	C => 3,
	D => 2,
	E => 1,
	F => 4,
	G => 2,
	H => 4,
	I => 1,
	J => 8,
	K => 5,
	L => 1,
	M => 3,
	N => 1,
	O => 1,
	P => 3,
	Q => 10,
	R => 1,
	S => 1,
	T => 1,
	U => 1,
	V => 4,
	W => 4,
	X => 8,
	Y => 4,
	Z => 10,
);


# Scrabble scoring
sub scrabble_wordscore {
	my $score = '0';
	my @letters = split (//, $_[0]);

	foreach my $letter (@letters) {
		$score += $scrabble_values{$letter};
        } 

	return $score;
}


#
# recursively generate a sorted list of every unique substring
#
sub substrings {
	my ($prefix, $pool, $list) = @_;

        #  $prefix - string to build upon 
        #         (empty string on first invocation)
        #
        #  $pool - suffix pool, ie. letters to use to generate suffixes
        #         (string of sorted, uppercase, input letters on first invocation)
        #
        #  $list - pointer to the list of all generated strings
        #         (empty list on first invocation)
        #
 
	# The prefix itself is a valid unique substring, so record it
        #   IFF it exists in the dictionary we are using

        if ( exists $dict{$prefix} ) {

                #print "--- $prefix \n";
                push @$list, $prefix;

        }

        # for each unique letter in the suffix pool, add it to the prefix and recurse
        # after that recursion returns put that letter on the front side ofthe suffix pool 
        # and grab the next letter from the back side

        my @sfront;                    # front, used portion of the suffix pool
        my $ltr;                       # letter from the suffix pool to be used
	my @sback = split(//, $pool);  # back, unused portion of the suffix pool

        while (scalar @sback > 0 ) {

                $ltr = shift @sback;

                # there can be duplicate letters in the suffix pool
                if ( ( scalar @sfront == 0 ) || ( $ltr ne $sfront[-1] ) ) {

                        substrings( $prefix . $ltr, join('', @sfront) . join('', @sback), $list);

                } 

                push @sfront, $ltr;
                
        }

}






print "Loading wordlist...\n";
open (WL, $wordfile) or die "Where's $wordfile?";
while (<WL>)
{
	chomp;
	$dict{$_} = 1;
}
print "... done.\n";
#print "---\n";


# main loop
print "> ";
while (<>)
{
	chomp;
	my $input = join('', sort split(//, uc $_) );
        print "\n";

        # generate the list of words from this input
	my @words;
	substrings('', $input, \@words);


        # score each word
	my %scores;
	foreach my $word (@words) {
		$scores{$word} = scrabble_wordscore($word);
	}

        my $nw = scalar @words;
        print "\nFound $nw words, in this dictionary: $dictname, using these letters: $input \n";


        # display the words, sorted by score
        print "\n";
	foreach my $word (sort { $scores{$a} <=> $scores{$b} } keys %scores) {
		printf ("  %10s  --  %2d   \n", $word, $scores{$word});
	}
	print "\n> ";
}

