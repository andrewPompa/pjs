#!/usr/bin/perl
#while(<>) { print unless(/^#/);}
# <> - iterator który przechodzi po wszystkich liniach wejścia - zmienna która generuje iterator to
# $_ - jest zmienną domyślną wielu operacji
# /^#/ - operator dopasowania wyrażenia reguralnego mogę tak: m$^#$, mogę tak: m\^#\
# m - match
# opcje
# -N nie wyrzucaj na output linijek która zaczyna się na #
# -c numeruj wszystkie linie jak leci
# -n numeruj po kolei
# -p numeruje linijki w każdym pliku z osobna
# mogę zrobić tak $.=0
# brak opcji - proste cat

use strict;
use warnings FATAL => 'all';
use Getopt::Long qw(:config no_ignore_case);
use feature qw(say);

my $dont_show_me_hash_lines = '';
my $show_me_all_lines_numbers = '';
my $show_me_only_visible_lines_numbers = '';
my $show_me_lines_numbers_separately_for_file = '';
GetOptions (
    'N' => \$dont_show_me_hash_lines,
    'c' => \$show_me_all_lines_numbers,
    'n' => \$show_me_only_visible_lines_numbers,
    'p' => \$show_me_lines_numbers_separately_for_file
);
if ($show_me_all_lines_numbers && $show_me_only_visible_lines_numbers) {
    die("opcje -c i -n nie mogą być użyte jednocześnie!");
}
my $line_number;
while (<>) {
    if ($show_me_all_lines_numbers) {
        $line_number = $.;
    }
    elsif ($show_me_only_visible_lines_numbers && ($dont_show_me_hash_lines && /^#/)) {
        $.--;
    }
    $line_number = $.;
    if (($dont_show_me_hash_lines && !/^#/) || !$dont_show_me_hash_lines) {
        if ($show_me_only_visible_lines_numbers || $show_me_all_lines_numbers) {
            print "$line_number: ";
        }
        print "$_";
    }
    if ($show_me_lines_numbers_separately_for_file) {
        $. = 0 if eof;
    }
}