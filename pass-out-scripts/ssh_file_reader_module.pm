#!/usr/bin/perl
package ssh_file_reader_module;
use strict;
use DateTime qw();
use DateTime::Format::Strptime;
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
    my $date_string = $_[0];
    my @ranges;
    my @date_arguments = split(/,/, $date_string);
    for my $date (@date_arguments) {
        if ($date =~ /.*;.*/) {
            my @date_ranges = split(/;/, $date);
            my $range = get_date_range_from_string_arguments($date_ranges[0], $date_ranges[1]);
            push(@ranges, $range);
            next;
        }
        my $range = get_date_range_string_argument($date);
        push(@ranges, $range);
    }
    return @ranges;
}
sub get_date_range_from_string_arguments {
    my $string_range_1 = shift;
    my $string_range_2 = shift;
    my $range_1;
    my $range_2;

    my @date_time = split(/ /, $string_range_1);
    if ($#date_time == 1) {
        $range_1 = get_full_date($date_time[0], $date_time[1]);
    } else {
       $range_1 = get_full_date($date_time[0], "00:00:00");
    }
    @date_time = split(/ /, $string_range_2);
    if ($#date_time == 1) {
        $range_2 = get_full_date($date_time[0], $date_time[1]);
    } else {
        $range_1 = get_full_date($date_time[0], "23:59:59");
    }
    return {range_1 => $range_1, range_2 => $range_2};
}
sub get_date_range_string_argument {
    my $string_range = shift;
    my $range_1;
    my $range_2;

    my @date_time = split(/ /, $string_range);
    if ($#date_time == 1) {
        print "[WARN]\tPrzedział $string_range jest podany z dokładną datą i zostanie sprawdzona tylko jedna sekunda!\n";
        print "\tCzy to pożądane użycie? Rozważ podanie argumentu w formacie yyyy-mm-dd dla przeszukania całego dnia\n";
        $range_1 = get_full_date($date_time[0], $date_time[1]);
        $range_2 = get_full_date($date_time[0], $date_time[1]);
    } else {
       $range_1 = get_full_date($date_time[0], "00:00:00");
       $range_2 = get_full_date($date_time[0], "23:59:59");
    }
    return {range_1 => $range_1, range_2 => $range_2};
}
sub get_full_date {
    my $date_to_split = shift;
    my $time_to_split = shift;
    my @date = split(/-/, $date_to_split);
#    if ($#date_time == 1) {
        my @time = split(/:/, $time_to_split);
        my $to_return = DateTime->new(
            year    => $date[0],
            month   => $date[1],
            day     => $date[2]
        );
        $to_return -> set_hour($time[0]);
        $to_return -> set_minute($time[1]);
        $to_return -> set_second($time[2]);
        return $to_return;
#    }
#    return DateTime->new(
#        year  => $date[0],
#        month => $date[1],
#        day   => $date[2]
#    );
}
sub get_date_from_string_pattern {
    my $date = shift;
    my $pattern = shift;
#    print "$date, $pattern\n";
    my $parser = DateTime::Format::Strptime->new( pattern => $pattern );
    my $dt = $parser->parse_datetime( $date );
    return $dt;
}
sub get_year_from_epoch_time {
    my $epoch_time = shift;
    my $to_return = DateTime->from_epoch(epoch => $epoch_time);
    return $to_return->year();
}
1;
