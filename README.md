# pjs
Zadania na Pracownię Języków Skryptowych
### Założenia ogólne:
+ skrypt zawsze opisuje co robi **-h, --help**
## ETAP 1 - Powłoki
Skrypt wyświetla informacje o użytkowniku: jego imię i nazwisko, jeżeli taka informacja nie istnieje wyświetla jego login
+ -h, --help jest to parametr o najwyższym priorytecie
    Kiedy będzie syf i -h wyświetla informacje i exit 1
    Kiedy będzie -h i -q lub samo -h  wyświetla informacje i exit 0
+ -q, --quiet tryb cichy: parametr o mniejszym priorytecie *Nie rób nic*
