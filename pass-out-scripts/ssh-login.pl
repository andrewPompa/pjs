#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

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
    print "app.yml plik z danymi do bazy danych\n";
    print "[-d przedział czasowy] parametr w formacie 'yyyy-mm-dd [HH:MM:SS]' godzina może zostać pominięta jeżeli chcemy przeszukać cały dzień\n";
    print "możemy określić przedział 'od:do' lub wyszczególnić dni: 'data,data,data'\n";
    print "np. '2018-02-02 12:00:10:2018-02-03 13:00:20,2018-02-04'\n";
}
show_help;