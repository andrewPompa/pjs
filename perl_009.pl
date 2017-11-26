#!/usr/bin/perl
require NumberValidator;

use strict;
use warnings FATAL => 'all';
use Getopt::Long qw(:config no_ignore_case);
use feature qw(say);
use bytes;

my $showBytes = '';
my $showScientificNumber = '';
my $showInt = '';
my $countWithoutHashCharStartingLine = '';
my $showLines = '';
my $showWords = '';
my $noOptionSet;

my $bytesInFile = 0;
my $linesInFile = 0;
my $wordsInFile = 0;
my $scientificNumbersInFile = 0;
my $intsInFile = 0;
my %fileInfoMap;

GetOptions (
    'd' => \$showScientificNumber,
    'i' => \$showInt,
    'e' => \$countWithoutHashCharStartingLine,
    'c' => \$showBytes,
    'l' => \$showLines,
    'w' => \$showWords,
);
if (!$showBytes && !$showLines && !$showWords && !$showInt && !$showScientificNumber) {
    $noOptionSet = 1;
}

while ($#ARGV >= 0) {
    my $myFile = shift;
    my $fh;
    my @words;
    if (!-e $myFile) {
        say STDERR "[ERROR] Plik $myFile nie istnieje!";
        next;
    }

    open($fh, "<", $myFile);
    while (<$fh>) {
        if ($countWithoutHashCharStartingLine && /^#/) {
            print "line starting with # skipping\n";
            next;
        }

        undef @words;
        @words = split;

        $bytesInFile += bytes::length($_);
        ++$linesInFile;
        $wordsInFile += $#words + 1;
        foreach my $word (@words) {
            if (NumberValidator::isInt($word)) {
                ++$intsInFile;
            }
            if (NumberValidator::isScientificNotation($word)) {
                ++$scientificNumbersInFile;
            }
        }


    }
    $fileInfoMap{$myFile}{bytes} = $bytesInFile;
    $fileInfoMap{$myFile}{lines} = $linesInFile;
    $fileInfoMap{$myFile}{words} = $wordsInFile;
    $fileInfoMap{$myFile}{ints} = $intsInFile;
    $fileInfoMap{$myFile}{scientificNumbers} = $scientificNumbersInFile;
    $bytesInFile = 0;
    $linesInFile = 0;
    $wordsInFile = 0;
    $intsInFile = 0;
    $scientificNumbersInFile = 0;
}


for my $fileInfo (keys %fileInfoMap) {
    if ($showScientificNumber) {
        print "scientific numbers: $fileInfoMap{$fileInfo}{scientificNumbers}, ";
    }
    if ($showInt) {
        print "ints: $fileInfoMap{$fileInfo}{ints}, ";
    }
    if ($showWords || $noOptionSet) {
        print "words: $fileInfoMap{$fileInfo}{words}, ";
    }
    if ($showLines || $noOptionSet) {
        print "lines: $fileInfoMap{$fileInfo}{lines}, ";
    }
    if ($showBytes || $noOptionSet) {
        print "bytes: $fileInfoMap{$fileInfo}{bytes}";
    }
    print " $fileInfo\n";
}