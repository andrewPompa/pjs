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

1;