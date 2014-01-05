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


use strict;
use warnings;
use autodie;

use File::Copy;


if(!($ARGV[0] =~ m/.*\.lsl/))
{
  system("emacsclient", "-nc", $ARGV[0] );
  exit(0);
}


my $table = "../replaceassignments.txt";

open my $script, "<", $ARGV[0];
my $line = <$script>;
close $script;
chomp $line;
$line =~ s!// =!!g;
if( ( !($line =~ m/.*\.o/) ) && ( !($line =~ m/.*\.i/) )  ) {
    system("emacsclient", "-c", $ARGV[0], $table);
    exit;
}

$line .= ": ";
my $replacementfile = undef;
open my $assign, "<", $table;
while( <$assign> ) {
  chomp $_;
  if( m/$line/) {
    $replacementfile = $';
    last;
  }
}
close $assign;

if( !($replacementfile =~ m/.*\.o/) && !($replacementfile =~ m/.*\.i/) ) {
  system("emacsclient", "-c", $ARGV[0], $table);
}
else {
#  sleep 2;
  $line =~ s/: $//;
  if($line =~ m/.*\.i/) {
    ## insert the file name at the top
    open $assign, ">", $ARGV[0];
    print $assign "// =" . $line . "\n";
    open $script, "<", $replacementfile;
    while( <$script> ) {
      print $assign $_;
    }
    close $script;
    close $assign;
  }
  else {
    ## file name is already in first line
    copy($replacementfile, $ARGV[0] );
  }
}
