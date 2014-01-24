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
# addtotable.pl: create entries in the lookup table used with replace.pl
#

use strict;
use warnings;
use autodie;

use POSIX qw(strftime);
use File::Basename;


use constant TABLE_INDICATOR => "-is-in-lookup-table";


# create a check-file to avoid unnecessary lookups
#
sub create_checkfile
  {
    my ($dir, $uniq, $entry) = @_;

    $uniq =~ s!.*/!!;
    my $fn = $dir . $uniq . TABLE_INDICATOR;

    open my $fh, ">>", $fn;
    printf $fh "[%s]: %s is in the lookup table\n", strftime("%Y-%m-%d %H:%M:%S", localtime), $entry;
    close $fh;
  }


# see if the check-file exists
#
sub has_checkfile
  {
    my ($dir, $uniq) = @_;

    $uniq =~ s!.*/!!;
    my $fn = $dir . $uniq . TABLE_INDICATOR;

    if(-e $fn)
      {
	return 1;
      }

    return 0;
  }


# expect two parameters which will be key and value for the entry into
# the lookup-table
#
my ($key, $value) = @ARGV;

# check whether they look ok or not
#
unless(defined($key) && defined($value) && ($key =~ m!src/.*\.lsl$!) && ($value =~ m!/.*/bin/.*\.lsl$!))
  {
    print "usage: addtotable.pl <key> <value>\n\t<key> and <value> must match regular expressions\n";
    print "\t<key>  : $key\n" if(defined($key));
    print "\t<value>: $value\n" if(defined($value));
    exit(1);
  }

# prepare the key for looking it up in and writing it to the lookup
# table
#
$key =~ s!src/!!;
$key =~ s/\.lsl$/\.o/;

# prepare the value to write it to the table together with the key
#
$value =~ s/\.lsl$/\.o/;

# avoid searching the lookup table when the entry has alread been
# created --- I like efficiency ...
#
my $checkdir = $value;
$checkdir =~ s!/bin/.*!/dep/!;

if(1 == has_checkfile($checkdir, $key))
  {
#    print "$key appears to be already in table for there is a checkfile\n";
    exit(0);
  }


# the file name of the lookup table
#
# THIS MUST BE THE SAME FILE AS IS USED WITH replace.pl
#
my $table = dirname(__FILE__) . "/../make/replaceassignments.txt";

if(-e $table)
  {
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
	    if( m/^$key/)
	      {
		# nothing further to do because the key is already in the table
		#
		close $assign;
		create_checkfile($checkdir, $key, $key);
#		print "$key is already in table; checkfile created\n";
		exit(0);
	      }
	  }
      }
    close $assign;
  }
else
  {
    # create the table when it doesn´t exist
    #
    open my $fh, ">>", $table;
    printf $fh "// [%s]: lookup-table created\n", strftime("%Y-%m-%d %H:%M:%S", localtime);
    close $fh;
  }

# write key and value to the lookup table
#
open my $assign, ">>", $table;
printf $assign "\n// [%s]: added %s\n", strftime("%Y-%m-%d %H:%M:%S", localtime), $key;
print $assign $key . ": " . $value . "\n";
close $assign;

create_checkfile($checkdir, $key, $key);

# printf "// [%s]: added %s to lookup-table\n", strftime("%Y-%m-%d %H:%M:%S", localtime), $key;
exit(0);
