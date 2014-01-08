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


# usage: replace.pl <filename>
#
# replace file A with file B when the first line of file A is a key
# found in a look-up table; file B is specified by the value of the
# key
#
# Entries in the look-up table are lines.  Each line holds a key-value
# pair, seperated by a colon and a space: 'key: value'.
#


use strict;
use warnings;
use autodie;

use POSIX qw(strftime);


# expect two parameters which will be key and value for the entry into
# the lookup-table
#
my ($key, $value) = @ARGV;
chomp $key;
chomp $value;

# check whether they look ok or not
#
unless(defined($key) && defined($value) && ($key =~ m!^src/.*\.lsl$!) && ($value =~ m!^/.*/bin/.*\.lsl$!))
  {
    print "usage: addtotable.pl <key> <value>\n\t<key> and <value> must match a regular expression\n";
    exit(1);
  }

# prepare the key for looking it up in the lookup table
#
$key =~ s!src/!!;
$key =~ s/\.lsl$/\.o/;

# the file name of the lookup table; specify an absolute path here
#
# THIS MUST BE THE SAME FILE AS IS USED WITH replace.pl
#
my $table = "/home/lee/Datenquellen/secondlife/scripts/replaceassignments.txt";


# look up the key in the lookup table
#
open my $assign, "<", $table;
while( <$assign> )
  {
    # ignore lines starting with "//" as comments
    #
    unless( m!^//!)
      {
	chomp $_;
	if( m/$key/)
	  {
	    # nothing further to do because the key is already in the table
	    #
	    close $assign;
	    exit(0);
	  }
      }
  }
close $assign;


# prepare the value to write it to the table together with the key
#
$value =~ s/\.lsl$/\.o/;

open $assign, ">>", $table;
printf $assign "\n// [%s]: added %s\n", strftime("%Y-%m-%d %H:%M:%S", localtime), $key;
print $assign $key . ": " . $value . "\n";
close $assign;

# printf "// [%s]: added %s to lookup-table\n", strftime("%Y-%m-%d %H:%M:%S", localtime), $key;
exit(0);
