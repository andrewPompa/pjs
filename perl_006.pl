#!/usr/bin/perl

use warnings FATAL => 'all';
#use strict;
sub validate_number {
    my @args = @_;
    if (!$args[0]) {
        die("[ERROR] należy podać dwa argumenty liczbowe!")
    }
    if ($args[0] !~ /^\d+$/) {
        die("[ERROR] $args[0] nie jest liczbą!");
        print STDERR "!";
    }
}

my $firstNumber;
$firstNumber = shift;
validate_number($firstNumber);

my $secondNumber;
$secondNumber = shift;
validate_number($secondNumber);

if ($firstNumber > $secondNumber) {
    my $tmp = $secondNumber;
    $secondNumber = $firstNumber;
    $firstNumber = $tmp;
}
--$firstNumber;
--$secondNumber;

while ($#ARGV >= 0) {
    my $my_file = shift;
    if (!-e $my_file) {
        say STDERR "[ERROR] Plik nie istnieje!";
        next;
    }
    my $fh;
    open($fh, "<", $my_file);
    while (<$fh>) {
        chomp;
        my @words = split;
        if ($secondNumber > $#words) {
            print "\n";
            next;
        }
        print join(' ', $words[$firstNumber], $words[$secondNumber]);
        print "\n";
    }
}