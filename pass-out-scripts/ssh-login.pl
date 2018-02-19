#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use IO::Uncompress::Gunzip qw($GunzipError);
use File::stat;
use JSON qw(decode_json);
#very important!!!
#sudo perl -MCPAN -e 'install JSON'

my $lib_name = 'YAML::XS';
my $configuration_file;
my $auth_log_path = "/home/mijo/Desktop/auth-log/*";
my %auth_files;
#my $auth_log_path = "/var/log/auth.log*";



sub can_use_lib {
    eval("use $_[0]");
    if ($@) {
        return(0);
    }
    else {
        return(1);
    }
}

if (!can_use_lib($lib_name)) {
    die("[ERROR] Nie można odnaleźć biblioteki '$lib_name' jest niezbędna do poprawnego działania programu\n");
    exit 2;
}
use YAML::XS;

$lib_name = 'DateTime';
#$lib_name = 'YAML::XS';
if (!can_use_lib($lib_name)) {
    say STDERR("[ERROR] Nie można odnaleźć biblioteki '$lib_name' jest niezbędna do poprawnego działania programu, użyj:\nperl -MCPAN -e 'install Bundle::DateTime::Complete'");
    exit 2;
}
use lib qw(./);
if (!can_use_lib("ssh_file_reader_module")) {
    die("[ERROR] Nie można odnaleźć biblioteki 'ssh_file_reader_module' moduł powinien znajdować się w katalogu ze skryptem\n");
    exit 2;
}
use ssh_file_reader_module;
use REST::Client;
add_localization_data();
sub show_help {
    print "Skrypt zbiera adresy z logów systemowych ssh(/var/log/auth.log*), z których nastąpiła próba zalogowania na serwer\n";
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
    if ($#ARGV == - 1) {
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
sub prepare_auth_files() {
    my @files = glob($auth_log_path);

    foreach my $file_name (@files) {
        if (!-r $file_name) {
            say STDERR "[ERROR] Plik $file_name nie może zostać odczytany!";
            next;
        }
        get_auth_file_info($file_name);
    }
}
sub get_auth_file_info() {
    my $file_name = shift;
    my $file_handler;
    my $first_date;
    my $last_date;
    my $is_first_line = 1;
    if ($file_name =~ /.*\.gz$/) {
        $file_handler = IO::Uncompress::Gunzip->new($file_name)
    }
    else {
        open($file_handler, "<", $file_name);
    }
    print "reading file: $file_name\n";
    while (<$file_handler>) {
        if ($is_first_line && $_ =~ /(\w{3}\s+\w+ \d\d:\d\d:\d\d)/) {
            $is_first_line = 0;
            $first_date = $_;
        }
        $last_date = $_;
    }
    $first_date =~ /(\w{3}\s+\w+ \d\d:\d\d:\d\d)/;
    $first_date = $1;
    #    print "last: $last_date\n";
    $last_date =~ /(\w{3}\s+\w+ \d\d:\d\d:\d\d)/;
    $last_date = $1;
    my $file_stats = stat($file_name);
    my $year = ssh_file_reader_module::get_year_from_epoch_time($file_stats->mtime);
    my $start_datetime =
        ssh_file_reader_module::get_date_from_string_pattern("$year $first_date", '%Y %b %d %H:%M:%S');
    my $end_datetime =
        ssh_file_reader_module::get_date_from_string_pattern("$year $last_date", '%Y %b %d %H:%M:%S');
    print "$start_datetime, $end_datetime\n";
    $auth_files{$file_name}{name} = $file_name;
    $auth_files{$file_name}{start_datetime} = $start_datetime;
    $auth_files{$file_name}{end_datetime} = $end_datetime;

}
sub read_file {
    my $file = shift;
    my $start_date = shift;
    my $end_date = shift;
    my $file_handler;
    if ($file->{name} =~ /.*\.gz$/) {
        $file_handler = IO::Uncompress::Gunzip->new($file->{name})
    }
    else {
        open($file_handler, "<", $file->{name});
    }
    my $file_stats = stat($file->{name});
    my $year = ssh_file_reader_module::get_year_from_epoch_time($file_stats->mtime);
    my %users;
    while (<$file_handler>) {
        if ($_ !~ /(\w{3}\s+\w+ \d\d:\d\d:\d\d).*/) {
            next;
        }
        if ($_ !~ /Accepted \w+ for \w+ from.*$/ &&
            $_ !~ /.*authentication failures.*rhost.*$/) {
            # Accepted password for test from 100.150.100.13 port 61961 ssh2
            # PAM 2 more authentication failures; logname= uid=0 euid=0 tty=ssh ruser= rhost=59.63.188.36  user=root
            next;
        }
        $_ =~ /(\w{3}\s+\w+ \d\d:\d\d:\d\d)/;
        my $date = $1;
        my $datetime =
            ssh_file_reader_module::get_date_from_string_pattern("$year $date", '%Y %b %d %H:%M:%S');
        if ($start_date->epoch() >= $datetime->epoch()) {
            next;
        }
        if ($end_date->epoch() < $datetime->epoch()) {
            print "end of processing $file->{name}\n";
            last;
        }
        if ($_ =~ /Accepted \w+ for \w+ from.*$/) {
            $_ =~ /^.*for (\w+) from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*$/;
            my $timestamp = $datetime->epoch();
            print "$timestamp, $1, $2\n";
            $users{$timestamp}{user} = $1;
            $users{$timestamp}{ip} = $2;
            $users{$timestamp}{result} = 'accepted';
        }
        else {
            print "line: $_\n";
            $_ =~ /^.*rhost=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+user=(\w+).*$/;
            my $timestamp = $datetime->epoch();
            if (defined $2) {
                $users{$timestamp}{user} = $2;
            }
            else {
                $users{$timestamp}{user} = 'not_found';
            }
            $users{$timestamp}{ip} = $1;
            $users{$timestamp}{result} = 'failure';
            #            print "$timestamp, $users{$timestamp}{user}, $users{$timestamp}{ip}\n";

        }
    }
    return %users;
}
sub add_localization_data {
    my $ip = shift;
    my $country;
    my $city;
    my $zip_code;
    my $client = REST::Client->new();
    $client->GET("http://freegeoip.net/json/$ip");
    my $decoded = decode_json($client->responseContent());
    return {country_name => $decoded->{$country}, $decoded->{city => $city}, zip_code => $decoded->{$zip_code}};
}
if (is_help_option()) {
    show_help();
    exit 1;
}
validate_configuration();
validate_date_option();
my @date_rages = ssh_file_reader_module::convert_date_argument_to_date_ranges($ARGV[2]);
prepare_auth_files();
my %users;
foreach my $date_range (@date_rages) {
    print "date range: ", $date_range->{range_1}->epoch(), " ", $date_range->{range_2}->epoch(), "\n";
    for my $file (keys %auth_files) {
        print "$file: ", $auth_files{$file}{start_datetime}->epoch(), " ", $auth_files{$file}{end_datetime}->epoch(),
            "\n";
        if ($date_range->{range_1}->epoch() >= $auth_files{$file}{start_datetime}->epoch() &&
            $date_range->{range_1}->epoch() <= $auth_files{$file}{end_datetime}->epoch()) {
            print "searching in: $file\n";
            my %users_from_file = read_file($auth_files{$file}, $date_range->{range_1}, $date_range->{range_2});
            for my $timestamp (keys %users_from_file) {
                $users{$timestamp}{user} = $users_from_file{$timestamp}{user};
                $users{$timestamp}{ip} = $users_from_file{$timestamp}{ip};
                $users{$timestamp}{result} = $users_from_file{$timestamp}{result};
            }
        }
    }
}
#add_localization_data(\%users);
for my $timestamp (keys %users) {
    my %localization_data = add_localization_data($users{$timestamp}{ip});
#    todo: add info and save on server
#    print "$users{$timestamp}{user}\n";
}
#1517443200 | 1518333904
#1517443200 | 1518220803
#1517443200 | 1517124303 | 1517443158
#1517443200 | 1516605905
#1517443200 | 1515914706