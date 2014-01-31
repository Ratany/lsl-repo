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

use POSIX qw(strftime);
use File::Basename;


#use constant OUTFILE => "/autoversion-";
use constant OUTFILE => "/";
use constant MANUALV => "version";


my ($project, $script, $outdir) = @ARGV;

unless(defined($project) && defined($script) && defined($outdir))
  {
    print "usage: getversion.pl <project-directory> <script[.i]> <output-directory>\n";
    exit(1);
  }

unless(-d $outdir)
  {
    print "directory $outdir not found\n";
    exit(1)
  }

# Figure out which file to use:
#
# Either use MANUALV or a particular file for the script that is
# processed if the particular file exists.
#
$script = basename($script);
$script =~ s/\..*$//;
my $thisversion = MANUALV . "-" . $script;


unless(-e $thisversion)
  {
    # script specific file does not exist, try default
    #
    $thisversion = MANUALV;
  }

# read version either from file or from git, file takes precendence
#
my $version = "";

if(-e $thisversion)
   {
     open my $fh, "<", $thisversion;
     $version = <$fh>;
     close $fh;

     unless(defined($version))
       {
	 # the file was empty
	 #
	 $version = "";
       }
     else
       {
	 chomp $version;
       }

     $project = "";
   }
else
  {
    # neither default, nor script specific file exist,
    # try git
    #
    if(-d ".git")
      {
	$version = `git rev-list --max-count=1 HEAD`;
	chomp $version;

	# add compile time since not every time make is run, all
	# changes have been commited
	#
	$version .= " " . strftime("%Y-%m-%d %H:%M:%S", localtime);
      }

    $project .= "-";
  }


open my $fh, ">", $outdir . OUTFILE . $script . ".h";

print $fh "#ifndef _VERSION_$script\n#define _VERSION_$script\n\n";

unless($version eq "")
  {
    print $fh "#define VERSION \"" . $project . $version . "\"\n";
  }
else
  {
    # the version is undefined
    #
    print $fh "#undef VERSION" . "\n";
  }

print $fh "\n#endif  // _VERSION_$script\n";

close $fh;

exit(0);
