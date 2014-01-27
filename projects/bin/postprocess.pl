#!/bin/perl


# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

#
# postprocess.pl: remove preprocessing-artifacts
#
# After some trying, I have given up trying to figure out how to
# reliably remove multiple semicolons outside of double quotes with
# sed.  Apparently that is a non-trivial problem ...
#

use strict;
use warnings;
use autodie;

use Text::ParseWords;


#
# pipe the file through the script, like 'cat <file> | postprocess.pl'
#


LINE: while ( my $line = <> )
  {

    # print "-l< $line\n";

    chomp $line;
    $line =~ s/\s+$//;

    if(my @garbage = parse_line(';', 1, $line))
      {
	foreach my $partof (@garbage)
	  {
	    if(defined($partof))
	      {
		if($partof =~ m/\S/)  # cpp doesn´t output obsolete whitespace anyway, but anyway ...
		  {
		    $partof =~ s/\s+$//;

		    # print "-p< $partof\n";

		    # leave for() loops untouched because they break up badly
		    #
		    if($partof =~ m/for\s*\(/)
		      {
			print $line . "\n";
			next LINE;
		      }

		    if($line =~ m/(;|})$/)
		      {
			# only add a semicolon when the line has one or ends with a bracket,
			# unless there is a bracket at the end of the line --- this is the
			# reason to remove all trailing whitespace from the components before
			# doing this
			#
			$partof .= ";" unless($partof =~ m/(}|{)$/);
		      }

		    print $partof . "\n";
		  }
	      }
	  }
      }
  }


exit(0);


# ... hm surprise!, it´s not exactly trivial in perl, either.
#
# This also solves the problem of doing
#
# s_};_}_g
# s_;;_;_g
#
# (which can break stuff) and of removing lines that contain nothing
# but whitespace and semicolons with sed.  It also makes formatting
# with astyle prettier by breaking up lines like { foobar; } which
# astyle doesn´t break the brackets off of.
#
# In case you ever need to undo what i2o.pl does for a script, add a
# newline after each semicolon which is not within quotes. Then pipe
# the script through postprocess.pl and then through astyle.  You get
# the formatting back.
