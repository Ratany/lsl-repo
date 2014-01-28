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


use constant OUTFILE => "lib/autoversion.h";
use constant MANUALV => "version";


my $project = "undetermined-";


# either read the version from the first line of a manually created
# file, or create it from the git revision if this seems to be a repo
#
my $version = "";

if(-e MANUALV)
   {
     open my $fh, "<", MANUALV;
     $version = <$fh>;
     close $fh;

     $project = "";
   }
else
  {
    # the project directory can be specified as parameter to be added to
    # the version
    #
    if(defined($ARGV[0]))
       {
	 $project = $ARGV[0] . "-";
       }

    if(-e ".gitignore")
      {
	$version = `git rev-list --max-count=1 HEAD`;
      }
  }


# the version is either undetermined or not
#
unless($version eq "")
  {
    chomp $version;
    $version = "#define VERSION \"$project" . "$version\"\n";
  }
else
  {
    $version = "#define VERSION \"$project" . "undetermined\"\n";
  }

open my $fh, ">", OUTFILE;
print $fh $version;
close $fh;


if(($version =~ m/undetermined/) || ($project =~ m/undetermined/))
   {
     print "Something is not fully determined. You can either create\n";
     print "the file \"" . MANUALV . "\" in the project directory\n";
     print "to use the first line of the file as version, or you can\n";
     print "have the version automatically created when the project\n";
     print "directory is a git repository.  When you run this script\n";
     print "with a command line argument, the first argument given will\n";
     print "be used as the first part of the version, unless the version\n";
     print "is given in the file \"" . MANUALV . "\".\n";
   }

exit(0);
