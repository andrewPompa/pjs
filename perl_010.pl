#!/usr/bin/perl
use lib qw(./);
require NumberValidator;

use strict;
use warnings FATAL => 'all';
use Getopt::Long qw(:config no_ignore_case);
use feature qw(say);
use bytes;

my %fileInfoMap;
my $fileCounter = 0;
print "---------------------------\n";
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
        undef @words;
        chomp;
        #        print "$_\n";
        if (!NumberValidator::isValidMarkRow($_)) {
            say STDERR "[ERROR][$myFile:$.] $_ - linia niepoprawna";
            next;
        }
        @words = split(/\s/, $_);
        my $name = ucfirst lc $words[0];
        my $surname = ucfirst lc $words[1];
        my $value = NumberValidator::convertMarkToNumber($words[2]);
        my $hash = "$surname$name";
        $fileInfoMap{$hash}{name} = $name;
        $fileInfoMap{$hash}{surname} = $surname;
        if (!exists($fileInfoMap{$hash}{numOfMarks})) {
            $fileInfoMap{$hash}{numOfMarks} = 0;
            $fileInfoMap{$hash}{sumOfMarks} = 0;
            my @marks = ();
            @{$fileInfoMap{$hash}{marks}} = @marks;
        }
        $fileInfoMap{$hash}{numOfMarks}++;
        $fileInfoMap{$hash}{sumOfMarks} += $value;
        push @{$fileInfoMap{$hash}{marks}}, $value;
    }
    print "---> Plik: $myFile\n";
    my @averages = ();
    for my $fileInfo (sort keys %fileInfoMap) {
        print "$fileInfoMap{$fileInfo}{surname} $fileInfoMap{$fileInfo}{name}: ";
        my $mark;
        my $first = 0;
        foreach $mark (@{$fileInfoMap{$fileInfo}{marks}}) {
            if ($first == 0) {
                $first = 1;
                print "$mark";
            }
            print ", $mark";
        }
        my $avg = $fileInfoMap{$fileInfo}{sumOfMarks} / $fileInfoMap{$fileInfo}{numOfMarks};
        push @averages, $avg;
        $avg = sprintf("%.2f", $avg);
        print ": $avg\n";
    }
    my $allAvg;
    my $avg;
    foreach $avg (@averages) {
        $allAvg += $avg;
    }
    $allAvg = $allAvg / ($#averages + 1);
    $allAvg = sprintf("%.2f", $allAvg);
    print "średnia dla całego pliku: $allAvg\n";
    print "---------------------------\n";
    ++$fileCounter;
}