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

use Getopt::Long qw(:config no_ignore_case);
use feature qw(say);

my $dont_show_me_hash_lines = '';	# option variable with default value (false)
my $show_me_all_lines_numbers = '';
my $show_me_only_no_hash_lines_numbers = '';
my $show_me_lines_numbers_separtelty_for_file = '';
GetOptions (
'N' => \$dont_show_me_hash_lines, 
'c' => \$show_me_all_lines_numbers,
'n' => \$show_me_only_no_hash_lines_numbers,
'p' => \$show_me_lines_numbers_separtelty_for_file
);
if ($show_me_all_lines_numbers && $show_me_only_no_hash_lines_numbers) {
	die("-c i -n nie może być użyta jednocześnie!");
}
#say "$show_me_hash_lines" ;
#say $show_me_all_lines_numbers;
#say $show_me_only_no_hash_lines_numbers;
#say $show_me_lines_numbers_separtelty_for_file;
my $c = 0
while(<>) { 
	if ($dont_show_me_hash_lines) {
		if (!/^#/) {
			if ($show_me_all_lines_numbers) {
				print"$.:$_";
			} else {
				$.--;
				print"$_";
			}
		} 
	}
	else {
		print"$_";
	}
	if ($show_me_lines_numbers_separtelty_for_file) {
			$.=0 if eof
	}

}
