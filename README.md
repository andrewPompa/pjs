# pjs
Zadania na Pracownię Języków Skryptowych
### Założenia ogólne:
+ skrypt zawsze opisuje co robi **-h, --help**
## ETAP 1 - Powłoki
### Zadanie 001
Skrypt wyświetla informacje o użytkowniku: jego login, imię i nazwisko, jeżeli taka informacja nie istnieje wyświetla jego login
+ Bez opcji - normalne działanie
+ -h, --help jest to parametr o najwyższym priorytecie: wyświetla informacje i kończy z kodem 0
+ -q, --quiet tryb cichy: parametr o mniejszym priorytecie *Nie rób nic*
+ każda inna opcja - dodanie komentarza *Niezrozumiale polecenie* i pomocy. Zakończenie działania z kodem 1.
+ - wywołanie z argumentem nie mającym wyglądu opcji jest ignorowane w tym
sensie, że program działa tak jakby był wywołany bez żadnych argumentów czy
opcji i kończy działanie z kodem błędu 0.
### Zadanie 002
#### 002
+ stderr - niepoprwany argument to co podał user, schodzę z kodem błędu 1
+ 003 - nieznany mi operator, lista obslugiwanych operatorow
jezeli cos jest nieosiagalne to *N/A*
Zamienić operatorów na literki
