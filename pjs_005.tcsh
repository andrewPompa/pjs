#!/bin/csh -f
#jazowski_michal grupa 2
set is_help=false
set is_client=false
set is_server=false
set port=12345
set ip="127.0.0.1"
set is_nc_openbsd = true

set counter=1
while ($#argv >= $counter)
  set var = $argv[$counter]
  echo "$var $counter"

   if ("$argv[$counter]" == '-h' || "$argv[$counter]" == '--help') then
    echo "Program działający w trybie serwer lub klient, serwer - zlicza liczbę swoich wywołań, klient otrzymuje tą liczbe"
    echo "Uzycie"
    echo "---------------"
    echo "Tryb serwer [domyślny]"
    echo "$0 [-s] [-p port] [-i ip]"
    echo "-s opcja domyślna tryb serwera"
    echo "-p port: wyszczególnienie portu (domyslnie 12345) na którym program ma nasłuchiwać kiedy port jest zajęty zwraca komunikat z błędem"
    echo "-i wyszczególnienie adresu ip (domyslnie 127.0.0.1) na którym port ma nasłuchiwać format x.x.x.x gdzie x jest liczbą od 0 do 255"
    echo "-h/--help pomoc"
    echo "---------------"
    echo "Tryb klient"
    echo "$0 -c [-p port] [-i ip]"
    echo "-c tryb klienta"
    echo "-p port: wyszczególnienie portu (domyslnie 12345) na którym program ma nasłuchiwać kiedy port jest zajęty zwraca komunikat z błędem"
    echo "-i wyszczególnienie adresu ip (domyslnie 127.0.0.1) na którym port ma nasłuchiwać format x.x.x.x gdzie x jest liczbą od 0 do 255"
    echo "-h/--help pomoc"
    exit 0
  else if ("X$argv[$counter]" == "X-s") then
      echo "is s"
      set is_server = true
  else if ("X$argv[$counter]" == "X-p") then
    @ counter++
    if ($#argv < $counter) then
      echo "[ERROR]: argument do -p jest wymagany!"
      exit 1
    endif
    set port = $argv[$counter]
    set cond = `expr $port : '^[0-9]\+$'`
    set n = `echo $port | wc -c`
    @ n--
    if ( $cond != $n ) then
      echo "[ERROR]: niepoprawna wartosc: $port powinnien byc to numer!"
      exit 1
    endif
  else if ("$argv[$counter]" == '-c') then
      set is_client = true
  else if ($argv[$counter] == '-i') then
    echo "is i"
    @ counter++
    if ($#argv < $counter) then
      echo "[ERROR]: argument do -i jest wymagany!"
      exit 1
    endif
    set ip = $argv[$counter]
    set cond = `expr $ip : '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'`
    set n = `echo $ip | wc -c`
    @ n--
    if ( $cond != $n ) then
      echo "[ERROR]: niepoprawna wartosc: $ip powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255"
      exit 1
    endif
    set ip_split_apart_1 = ($ip:as/./ /)
    foreach i ( $ip_split_apart_1 )
      if ($i > 255 || $i < 0) then
        echo "[ERROR]: niepoprawna wartosc: $ip powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255"
        exit 1
      endif
    end
  else if ($var == '-q') then
    echo "is q"
  endif

  @ counter++
end
echo "is_help: $is_help, cli: $is_client, ser: $is_server, ip: $ip, port: $port, is netcat-openbsd: $is_nc_openbsd"
