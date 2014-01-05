#!/bin/perl

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
