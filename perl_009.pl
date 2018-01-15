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
my $fileCounter = 0;
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
            print "[INFO] $. ($myFile) line starting with # skipping\n";
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
    $fileInfoMap{$fileCounter}{name} = $myFile;
    $fileInfoMap{$fileCounter}{bytes} = $bytesInFile;
    $fileInfoMap{$fileCounter}{lines} = $linesInFile;
    $fileInfoMap{$fileCounter}{words} = $wordsInFile;
    $fileInfoMap{$fileCounter}{ints} = $intsInFile;
    $fileInfoMap{$fileCounter}{scientificNumbers} = $scientificNumbersInFile;
    $bytesInFile = 0;
    $linesInFile = 0;
    $wordsInFile = 0;
    $intsInFile = 0;
    $scientificNumbersInFile = 0;
    ++$fileCounter;
}
my $shouldCountTotal;
if (scalar keys %fileInfoMap > 1) {
    $shouldCountTotal = 1;
    $fileInfoMap{total}{scientificNumbers} = 0;
    $fileInfoMap{total}{ints} = 0;
    $fileInfoMap{total}{words} = 0;
    $fileInfoMap{total}{lines} = 0;
    $fileInfoMap{total}{bytes} = 0;
}

for my $fileInfo (keys %fileInfoMap) {
    if ($fileInfo =~ "total") {
        next;
    }

    if ($showScientificNumber) {
        print "scientific numbers: $fileInfoMap{$fileInfo}{scientificNumbers}, ";
    }
    if ($showInt) {
        print "ints: $fileInfoMap{$fileInfo}{ints}, ";
    }
    if ($showLines || $noOptionSet) {
        print "lines: $fileInfoMap{$fileInfo}{lines}, ";
    }
    if ($showWords || $noOptionSet) {
        print "words: $fileInfoMap{$fileInfo}{words}, ";
    }
    if ($showBytes || $noOptionSet) {
        print "bytes: $fileInfoMap{$fileInfo}{bytes}";
    }
    print " $fileInfoMap{$fileInfo}{name}\n";

    if ($shouldCountTotal) {
        $fileInfoMap{total}{scientificNumbers} += $fileInfoMap{$fileInfo}{scientificNumbers};
        $fileInfoMap{total}{ints} += $fileInfoMap{$fileInfo}{ints};
        $fileInfoMap{total}{words} += $fileInfoMap{$fileInfo}{words};
        $fileInfoMap{total}{lines} += $fileInfoMap{$fileInfo}{lines};
        $fileInfoMap{total}{bytes} += $fileInfoMap{$fileInfo}{bytes};
    }
}
if ($shouldCountTotal) {
    if ($showScientificNumber) {
        print "scientific numbers: $fileInfoMap{total}{scientificNumbers}, ";
    }
    if ($showInt) {
        print "ints: $fileInfoMap{total}{ints}, ";
    }
    if ($showLines || $noOptionSet) {
        print "lines: $fileInfoMap{total}{lines}, ";
    }
    if ($showWords || $noOptionSet) {
        print "words: $fileInfoMap{total}{words}, ";
    }
    if ($showBytes || $noOptionSet) {
        print "bytes: $fileInfoMap{total}{bytes}";
    }
    print " total\n";
}