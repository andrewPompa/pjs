#!/bin/bash
#jazowski_michal grupa 2

# netcat.traditional - http://nc110.sourceforge.net/
# netcat.openbsd - http://man.openbsd.org/nc
# ważne różnice - https://www.quora.com/What-is-the-difference-between-the-openBSD-netcat-and-the-GNU-netcat
# najpewniej gnu to ubuntu - http://netcat.sourceforge.net/
# najpewniej openbsd to debian - http://man.openbsd.org/nc
# nc -v 127.0.0.1 12345
# nc -vl 127.0.0.1 -p 12345

is_help=false
is_client=false
is_server=false
port=12345
ip="127.0.0.1"

is_nc_openbsd=true

usage() {
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
}
validate_program_name() {
  name=`basename $0`
  local client_regexp='^client\..+$'
  local server_regexp='^serwer\..+$'
  if [[ $name =~ $client_regexp ]] ; then
    is_client=true
  fi
  if [[ $name =~ $server_regexp ]] ; then
    is_server=true
  fi
}
get_program_options() {
  while test $# -gt 0; do
    if [ $1 == --help ]; then
      usage
      exit 0
    fi
    shift
  done
  if [[ $is_server == false ]] && [[ $is_client == false ]]; then
    is_server=true
  fi
}

call_error() {
  echo "[ERROR]: niepoprawna wartosc: $1 powinniem byc to numer ip x.x.x.x gdzie x to liczby w przedziale od 0 do 255!" >&2
  exit 1
}
validate_ip () {
  local int_regexp='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
  if ! [[ $ip =~ $int_regexp ]] ; then
    call_error $ip
  fi
  local ip_tmp=$ip
  IFS='.' split_ip=($ip_tmp)
  for i in {0..3}; do
    if [ "${split_ip[$i]}" -gt 255 ] || [ "${split_ip[$i]}" -lt 0 ]; then
      call_error ${split_ip[$i]}
    fi
  done
  # echo "$ip"
}
validate_port() {
  local int_regexp='^[0-9]+$'
  if ! [[ $1 =~ $int_regexp ]] ; then
    echo "[ERROR]: niepoprawna wartosc portu: $1 powinna byc to liczba!" >&2
    exit 1
  fi
}
validate_program_options() {
  if [ "$is_help" == true ]; then
    usage
    exit 0
  fi
  if [ "$is_client" == true ] && [ "$is_server" == true ]; then
    echo "[ERROR] opcja -c i -s nie może być wywołana jednocześnie, sprawdż $0 -h/--help!" >&2
    exit 0
  fi
  validate_ip $ip
  validate_port $port
}
check_nc_version() {
  result=$(nc -vv |& cat | grep -o "netcat-openbsd")
  if [[ $result == "netcat-openbsd" ]]; then
    is_nc_openbsd=true
  else
    is_nc_openbsd=false
  fi
}
function get_server_counter_from_rc_file() {
  if [ -f ${HOME}/.licznik.rc ]; then
    echo $(cat ${HOME}/.licznik.rc)
  else
    echo 0 > ${HOME}/.licznik.rc
    echo 0
  fi
}
function set_server_counter_from_rc_file() {
  echo $1 > ${HOME}/.licznik.rc
}
start_server() {
  while [[ true ]]; do
    local first_attempt=$(nc -w 1 -zv "$ip" $port 2>&1)
    if  [[ $first_attempt == *'succeeded'* ]]; then
      echo "[ERROR]: adres w użyciu nie można uruchomić serwera" >&2
      exit 1
    fi
    echo $(get_server_counter_from_rc_file)
    local counter=$(get_server_counter_from_rc_file)
    $(echo $counter | nc -v -l "$ip" $port)
    counter=$(($counter + 1))
    set_server_counter_from_rc_file $counter
  done
}
serve_client() {
  local connection_result=$(nc -w 1 "$ip" $port 2>&1)
  # echo $connection_result
  local int_regexp='^[0-9]+$'
  if ! [[ $connection_result =~ $int_regexp ]] ; then
    echo "[ERROR]: połaczenie z serwerem się nie powiodło" >&2
    exit 1
  fi
  echo "Licznik serwera: $connection_result"
}
# #################################
# executions
# #################################
validate_program_name

while getopts ":h :c :s :i: :p:" opt; do
  case $opt in
    h)
      is_help=true;
    ;;
    c)
      is_client=true;
    ;;
    s)
      is_server=true;
    ;;
    i)
      echo $OPTARG;
      ip=$OPTARG;
    ;;
    p)
      port=$OPTARG;
    ;;
    \?)
      echo "[ERROR] Niepoprawna opcja: -$OPTARG!" >&2
      exit 1
    ;;
    :)
      echo "[ERROR] Opcja: $OPTARG wymaga argumentu!" >&2
      exit 1
    ;;
    *)
      echo $opt
    ;;
  esac
done
get_program_options
validate_program_options
check_nc_version
if [[ "$is_server" == true ]]; then
  start_server $ip $port
fi
if [[ "$is_client" == true ]]; then
  serve_client
fi
# echo "is_help: $is_help, cli: $is_client, ser: $is_server, ip: $ip, port: $port, is netcat-openbsd: $is_nc_openbsd"
