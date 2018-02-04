#!/usr/bin/perl
package ssh_file_reader_module;
use strict;
use warnings FATAL => 'all';

sub is_date_argument_valid {
    my $date_format = '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$';
    my $date_string = $_[0];
    my @dates = split(/,/, $date_string);
    for my $date (@dates) {
        if ($date =~ /.*;.*/) {
            my @date_ranges = split(/;/, $date);
            if ($#date_ranges != 1) {
                return 1;
            }
            if ($date_ranges[0] !~ /$date_format/o || $date_ranges[1] !~ /$date_format/o) {
                print "$date\n";
                return 2;
            }
            next;
        }
        if ($date !~ /$date_format/o) {
            print "$date\n";
            return 2;
        }
    }
    return 0;
}

sub convert_date_argument_to_date_ranges {
    my $date_string = 0;
    return 0;
}

1;
