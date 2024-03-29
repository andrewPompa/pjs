#!/bin/csh -f
#jazowski_michal grupa 2
set is_help = false
set is_client = false
set is_server = false
set port=12345
set ip="127.0.0.1"
set is_nc_openbsd = true


set name=`basename $0`
set cond = `expr $name : '^client\..+$'`
set n = `echo $name | wc -c`
@ n--
if ( $cond == $n ) then
  # echo "client"
  set is_client = true
endif

set cond = `expr $name : '^serwer\..+$'`
set n = `echo $name | wc -c`
@ n--
if ( $cond == $n ) then
  # echo "serwer"
  set is_server = true
endif

set counter=1
while ($#argv >= $counter)
  set var = $argv[$counter]
  # echo "$var $counter"

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
  endif

  @ counter++
end
if ( "$is_client" == false && "$is_server" == false) then
  set is_server = true
endif
if ( "$is_client" == true && "$is_server" == true) then
  echo "[ERROR] opcja -c i -s nie może być wywołana jednocześnie, sprawdż $0 -h/--help!"
  exit 0
endif

# echo "is_help: $is_help, cli: $is_client, ser: $is_server, ip: $ip, port: $port, is netcat-openbsd: $is_nc_openbsd"

set result = `nc -vv |& cat | grep -o "netcat-openbsd"`
if  ($result == "netcat-openbsd") then
  set is_nc_openbsd = true
else
  set is_nc_openbsd = false
endif

if ( $is_server == true ) then
  if ( -f ${HOME}/.licznik.csh ) then
  	set counter = `cat ${HOME}/.licznik.csh`
  else
  	echo 0 > ${HOME}/.licznik.csh
    set counter = `cat ${HOME}/.licznik.csh`
  endif

	echo "Startig server"
	while (1)
    alias test_port 'set test_port = ( `nc -w 1 $ip $port |& cat` ); echo $test_port'
    set test_port_result = `test_port`
    if ($#test_port_result != 0) then
      echo "[ERROR]: port w użyciu nie można uruchomić serwera"
      exit 1
    endif
    if ($is_nc_openbsd == true) then
        set var = `echo $counter | nc -l $ip $port`
    else
        set var = `echo "$counter" | nc -v -q 1 -l $ip -p $port`
    endif
    echo $counter
    @ counter++
		echo $counter > ${HOME}/.licznik.csh
	end
endif

if ( $is_client == true ) then
	echo "This is a client:"
	set result_client = `nc $ip $port `
	echo "response was:" $result_client
endif
