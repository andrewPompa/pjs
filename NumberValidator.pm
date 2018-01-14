#!/usr/bin/perl
package NumberValidator;
use strict;
use warnings FATAL => 'all';


sub isInt {
    return $_[0] =~ /^\d+$/;
}

sub isScientificNotation {
    return $_[0] =~ /^(:?[-+]?\.\d+|[-+]?\d+\.?\d*)(:?[eEdDQ\^][-+]?\d+)?$/;
}

sub isValidMarkRow {
    return $_[0] =~ /^(\w+\s){2}(:?[-+]?\d\.\d+|[-+]?\d|\d\.\d+[-+]?|\d[-+]?)$/;
}
sub convertMarkToNumber {
    my $valueToSet = 0;
    my $number = $_[0];

    $number = $number;
    if ($_[0] =~ /-/) {
        $valueToSet = -0.25;
    }
    if ($_[0] =~ /\+/) {
        $valueToSet = 0.25;
    }
    if ($_[0] =~ /\d+-/ || $_[0] =~ /\d+\+/) {
        $number = substr $number, 0, - 1;
    }
    $number = abs($number);
    $number += $valueToSet;
    return $number;
}

1;