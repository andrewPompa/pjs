#!/usr/bin/perl
use strict;
use lib qw(./);
use warnings FATAL => 'all';

sub can_use_lib {
    eval("use $_[0]");
    if ($@) {
        return(0);
    }
    else {
        return(1);
    }
}
my $lib_name = 'YAML::XS';
my $configuration_file;
my $search_all_directories = 1;

if (!can_use_lib($lib_name)) {
    die("[ERROR] Nie można odnaleźć biblioteki '$lib_name' jest niezbędna do poprawnego działania programu\n");
    exit 2;
}
use YAML::XS;

if (!can_use_lib("ssh_file_reader_module")) {
    die("[ERROR] Nie można odnaleźć biblioteki 'ssh_file_reader_module' moduł powinien znajdować się w katalogu ze skryptem\n");
    exit 2;
}
use ssh_file_reader_module;

sub show_help {
    print "Skrypt zbiera adresy z logów ssh, z których nastąpiła próba zalogowania na serwer\n";
    print "Na postawie adresów określane są dane takie jak:\n";
    print "- Login na który nastąpiła próba zalogowania\n";
    print "- Ostatnia próba logowania\n";
    print "- Ilość prób w wybranym przedziale czasowym\n";
    print "- Lokalizacja (region, kraj itp.) z którego pochodzi wybrany adres\n";
    print "Informacje te odkładane są w bazie danych i mogą zostać skonsumowane przez inne serwisy\n";
    print "-------\n";
    print "UŻYCIE:\n";
    print "$0 app.yml [-d przedział czasowy]\n";
    print "app.yml ścieżka do pliku z danymi do połączenia z Firebase(baza NoSQL)\n";
    print "[-d przedział czasowy]\tparametr w formacie 'yyyy-mm-dd [HH:MM:SS]' godzina może zostać pominięta jeżeli chcemy przeszukać cały dzień\n";
    print "\t\t\tmożemy określić przedział 'od;do' lub wyszczególnić dni: 'data,data,data'\n";
    print "\t\t\tnp. '2018-02-02 12:00:10;2018-02-03 13:00:20,2018-02-04'\n";
    print "\t\t\tjeżeli parametr nie zostanie podany zostaną przeszukane wszystkie dni\n";
}
sub is_help_option() {
    for my $option (@ARGV) {
        if ($option =~ "-h|--help") {
            return 1;
        }
    }
    return 0;
}
sub validate_configuration {
    if ($#ARGV == -1) {
        say STDERR("[ERROR] Proszę podać plik konfiguracji!");
        show_help
        exit 2
    }
    if (!-e $ARGV[0]) {
        say STDERR("[ERROR] Proszę podać plik konfiguracji!");
        show_help
        exit 2
    }
    $configuration_file = YAML::XS::LoadFile($ARGV[0]);
#    $configuration_file->{database}{url}
}
sub validate_date_option {
    if ($#ARGV == 1) {
        say STDERR("[ERROR] Niepoprawna ilość argumentów, oczekiwano '-d data'");
        show_help();
        exit 2;
    }
    if ($ARGV[1] !~ /^-d$/) {
        say STDERR("[ERROR] Niepoprawny parametr, oczekiwano '-d'");
        show_help();
        exit 2;
    }
    my $date_validation_result = ssh_file_reader_module::is_date_argument_valid($ARGV[2]);
    if ($date_validation_result == 1) {
        say STDERR("[ERROR] Niepoprawny przedział dat!");
        show_help();
        exit 2;
    }
    if ($date_validation_result == 2) {
        say STDERR("[ERROR] Niepoprawny format daty!");
        show_help();
        exit 2;
    }
}
if (is_help_option()) {
    show_help();
    exit 1;
}
validate_configuration();
validate_date_option();
my %date_rages = ssh_file_reader_module::convert_date_argument_to_date_ranges($ARGV[2]);