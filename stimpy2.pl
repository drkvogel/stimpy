#!/usr/bin/perl
#==============================================================================
# stimpy.pl
# Steering file importer for NOVA;
# Author: Chris Bird
# Date:  June 2011
#==============================================================================
#==list perl modules==
# instmodsh  # then type 'l'
#==mount a windows drive on linux===
# mkdir -p /mnt/ntserver
# mount -t cifs //ntserver/download -o username=vivek,password=myPassword /mnt/ntserver
#==find files containing xxx====
# find / -type f -exec grep -l "xxx" {} \;c
#find . -iname \*.bat -type f -exec grep -il "zip" {} \;

#zip up c:\bc\headbone
#ftp across to nrat
#'walk' dir 'tree', finding steering files (in perl?)

use 5.6.1;            #Set the version of Perl
use warnings;         #Turn on warnings, concise, Perl 5.6 and later
#use strict;           #Turn on scope for variables
use File::Copy;
use File::DirWalk;
use File::Spec;
use File::Spec::Functions;
use File::Basename;
#use DBI::Ingres

sub copy_files{
# Copy several files into a new one
# (array of files to be copied, file name for the new file)
    my ($file_list, $file_target) = @_;
    my @data, $i;
    if (!open(OUT, ">$file_target")) {
        print "GALAXYUTILS, copy_files() - Can't open file $file_target\n";
        return(FFALSE());
    }
    $i = 0;
    foreach (@{$file_list}) {
        if (!open(FILE, @$file_list[$i])) {
            print "GALAXYUTILS, copy_files() - Can't open file @$file_list[$i]\n";
            close(OUT);
            return(FFALSE());
        }
        while (@data = <FILE>) {
            print OUT @data;
        }
        close(FILE);
        $i += 1;
    }
    close(OUT);
    return(TTRUE());
}

print "home: ".$ENV{'HOME'}."\n";

#my $basedir = "/cygdrive/z/Linked Folders/Q55/NOVA/steering files";
my $basedir = "/cygdrive/c/CB";

my $dw = new File::DirWalk;
$dw->onFile(sub {
  # do stuff
  my ($file) = @_;
  my($name, $path, $suffix) = fileparse($file, qr/\.[^.]*/);
  if ($suffix eq ".DAT") {
    print "found steering file: $file\n ";
    if (!open(FILE, $file)) {
      return File::DirWalk::FAILED;
    }
    my $lastline = `tail -n 1 '$file'`;
    #print $lastline;
    my $ending = substr $lastline, 1, 8;
    #print "ending: '$ending'\n";
    #substr EXPR,OFFSET,LENGTH
    my($fork, $comparison, $descript1, $descript2);
    if ($ending eq "0000 0v0") {
      print "It's a steering file\n";
      my $lines = 0;
      while ($line = <FILE>) {
        if ($lines == 0) {
	  print "1st line";
	} elsif ($lines == 1) {
	  print "2nd line";
	} else {
          #print @line;
  	  ($fork, $comparison, $descript1, $descript2) = split (' ', $line);
	  print "fork: $fork, comparison: $comparison, descript1: $descript1, descript2: $descript2\n";
          # stick it in the laterbase;
	}
	$lines++;
      }
    } else {
      print "It's not a steering file\n";
    }
  }
  return File::DirWalk::SUCCESS;
});

$dw->walk($basedir);
#$dw->walk($ENV{'HOME'});