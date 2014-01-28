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

use File::Slurp qw( read_file prepend_file );
use File::Basename;


use constant LICENSEFILE => "license";


my $filename = $ARGV[0];

unless(defined($filename))
  {
    print "usage: addlicense.pl <filename>\n";
    exit(1);
  }

unless(-e $filename)
  {
    print $filename . " not found\n";
    exit(2);
  }


# Figure out which file to use:
#
# Either use LICENSEFILE or a particular license file for the file
# that is processed if the particular license file exists.
#
my $thislicense = LICENSEFILE . "-" . basename($filename);
$thislicense =~ s/\..*$//;

print "thisl: $thislicense\n";

my $uselicense = LICENSEFILE;

if(-e $thislicense)
  {
    $uselicense = $thislicense;
  }


# insert the license into the file
#
if(-e $uselicense)
  {
    my $license = read_file($uselicense);
    prepend_file($filename, $license);
  }

exit(0);
