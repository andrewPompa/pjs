#!/bin/csh -f
#jazowski_michal grupa 2
set is_help=false

foreach argument ( $argv )
  if ($argument == '-h' || $argument == '--help') then
    set is_help=true
  endif
end
if ($is_help == true) then
  echo "Sprawdza dostepnosc IP w przedziale od IP_1 do IP_2 wlacznie"
  echo "Uzycie"
  echo "$0 IP_1 IP_2"
  echo "IP_1 IP_2 - adres ip x.x.x.x"
  echo "Zwraca"
  echo "IP - zywy/martwy"
  exit 0
endif

set cond = `expr $1 : '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'`
set n = `echo $1 | wc -c`
@ n--
if ( $cond != $n ) then
  echo "[ERROR]: niepoprawna wartosc: $1 powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255"
  exit 1
endif

set cond = `expr $2 : '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'`
set n = `echo $2 | wc -c`
@ n--
if ( $cond != $n ) then
  echo "[ERROR]: niepoprawna wartosc: $2 powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255!"
  exit 1
endif
set ip_split_apart_1 = ($1:as/./ /)
set ip_split_apart_2 = ($2:as/./ /)
set ip_1
set ip_2
set mask_0=255
set mask_1=65280
set mask_2=16711680
set mask_3=4278190080

set part_1=0
set part_2=0
set part_3=0
set part_4=0
set counter=0


foreach i ( $ip_split_apart_1 )
  if ($i > 255 || $i < 0) then
    echo "[ERROR]: niepoprawna wartosc: $1 powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255"
    exit 1
  endif
  @ counter = $counter + 1
  if ($counter == 1) then
    @ part_4 = ($i << 24)
  else if ($counter == 2) then
    @ part_3 = ($i << 16)
  else if ($counter == 3) then
    @ part_2 = ($i << 8)
  else if ($counter == 4) then
    set part_1 = $i
  endif
end
@ ip_1 = $part_1 + $part_2 + $part_3 + $part_4

set part_1=0
set part_2=0
set part_3=0
set part_4=0
set counter=0
foreach i ( $ip_split_apart_2 )
  if ($i > 255 || $i < 0) then
    echo "[ERROR]: niepoprawna wartosc: $2 powinnien byc to adres ip x.x.x.x gdzie x jest liczba od 0 do 255"
    exit 1
  endif
  @ counter = $counter + 1
  if ($counter == 1) then
    @ part_4 = ($i << 24)
  else if ($counter == 2) then
    @ part_3 = ($i << 16)
  else if ($counter == 3) then
    @ part_2 = ($i << 8)
  else if ($counter == 4) then
    set part_1 = $i
  endif
end
@ ip_2 = $part_1 + $part_2 + $part_3 + $part_4
set starting_ip=$ip_1
set ending_ip=$ip_2
if ($ip_1 > $ip_2) then
  set starting_ip=$ip_2
  set ending_ip=$ip_1
endif
while ( $starting_ip <= $ending_ip )
  # echo 'pinging' $starting_ip
  @ part_1 = (($starting_ip & $mask_3) >> 24)
  @ part_2 = (($starting_ip & $mask_2) >> 16)
  @ part_3 = (($starting_ip & $mask_1) >> 8)
  @ part_4 = (($starting_ip & $mask_0 ))
  set ip_1 = "$part_1.$part_2.$part_3.$part_4"
  # alias test_ping 'ping -c 1 -w 1 $ip_1'
  alias test_ping 'ping -c 1 -w 1 $ip_1 | grep -o "1 received"'
  set test_t = 0
  set ping_result=0
  set ping_result=`test_ping`
  set test_t=$ping_result
  if ($test_t == "") then
    echo "$ip_1 martwy"
  else
    echo "$ip_1 zywy"
  endif
  # if ($ping_result == '1 received') then
  #   echo "ooo"
  # else
  #   echo "nooo"
  # endif
  # echo "$ip_1: martwy"
  # endif

  @ starting_ip++
end
