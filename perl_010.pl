#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
require NumberValidator;

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
        undef @words;
        chomp;
        #        print "$_\n";
        if (!NumberValidator::isValidMarkRow($_)) {
            say STDERR "[ERROR][$myFile:$.] $_ - linia niepoprawna";
            next;
        }
        @words = split(/\s/, $_);

#        foreach my $word (@words) {
            my $value = NumberValidator::convertMarkToNumber($words[2]);
            print "$words[2]: $value\n"
#        }
#        print "@words\n";
    }
    ++$fileCounter;
}