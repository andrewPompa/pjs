package NumberValidator;
use strict;
use warnings FATAL => 'all';

#!/usr/bin/perl

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
    if ($_[0] =~ /-/){
        $valueToSet = -0.25
        $number = substr
    }
    if ($_[0] =~ /\+/){
        $valueToSet = 0.25;
    }
    my
    return $valueToSet;
}

1;