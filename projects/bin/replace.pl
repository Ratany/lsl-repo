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

use File::Copy;


# the editor to use
#
# Note: Use an editor that waits before it exits until you are
# finished editing the file.  Your sl client stops monitoring the file
# when the editor exits (or forks off into the background) before
# you´re done editing, and it may not replace the contents of its
# built-in editor with the contents of the file you´re editing.
#
my $editor = "emacsclient";
#
# "-c" makes emacsclient create a new frame.  If you start your
# favourite editor without such a parameter, you want to remove
# $editorparam here an in the 'start_editor' function.
#
my $editorparam = "-c";


# a wrapper function to start the editor
#
sub start_editor
  {
    my (@files_to_edit) = @_;

    system($editor, $editorparam, @files_to_edit);
  }


# unless the filename given as parameter is *.lsl, edit the file
#
unless($ARGV[0] =~ m/.*\.lsl/)
{
  start_editor($ARGV[0]);
  exit(0);
}


# the file name of the lookup table; specify an absolute path here
#
my $table = "/absolute/path/to/replaceassignments.txt";


# read the first line of the file; unless it matches a pattern like
# "// =filename.[o|i]", edit the file and the lookup table
#
open my $script, "<", $ARGV[0];
my $line = <$script>;
close $script;
chomp $line;
$line =~ s!// =!!g;
unless(($line =~ m/.*\.o/) || ($line =~ m/.*\.i/))
  {
    start_editor($ARGV[0], $table);
    exit(0);
  }


# look up the key in the lookup table
#
$line .= ": ";
my $replacementfile = undef;
open my $assign, "<", $table;
while( <$assign> )
  {
    # ignore lines starting with "//" as comments
    #
    unless( m!^//!)
      {
	chomp $_;
	if( m/$line/) {
	  $replacementfile = $';
	  last;
	}
      }
  }
close $assign;

# when the value of the key looks ok, replace the file, otherwise edit
# the file and the table
#
if(($replacementfile =~ m/.*\.o/) || ($replacementfile =~ m/.*\.i/))
  {
    copy($replacementfile, $ARGV[0]);
  }
else
  {
    start_editor($ARGV[0], $table);
  }
