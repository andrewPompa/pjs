#!/bin/bash
#jazowski_michal grupa 2

mask_0=$((0x000000FF))
mask_1=$((0x0000FF00))
mask_2=$((0x00FF0000))
mask_3=$((0xFF000000))
PORT_FTP=21
PORT_SSH=22
PORT_SMTP=25
PORT_HTTP=80
PORT_HTTPS=443
CONNECTION_OK="polaczenie nawiazane"


usage() {
  echo "Wyswietla informacje o porcie otwartym na adresie IP podanym w przedziale od IP_1 do IP_2 wlacznie"
  echo "Uzycie"
  echo "$0 IP_1 IP_2 PORTS"
  echo "IP_1 IP_2 - adres ip x.x.x.x"
  echo "PORTS - lista portów oddzielona przecinkami np. 8080,443,22"
  echo "Zwraca"
  echo "IP:PORT - podstawowe informacje lub brak polaczenia w przypadku gdy port nie jest otwarty"
}
validate_usage() {
  local is_help=false
  while test $# -gt 0; do
    if [ $1 == -h ] || [ $1 == --help ]; then
      is_help=true
    fi
    shift
  done
  if [ "$is_help" == true ]; then
    usage
    exit 0
  fi
}
validate_string_input () {
  local int_regexp='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
  if ! [[ $1 =~ $int_regexp ]] ; then
    call_error $1
  fi
}
validate_port() {
  local int_regexp='^[0-9]+$'
  if ! [[ $1 =~ $int_regexp ]] ; then
    echo "[ERROR]: niepoprawna wartosc portu: $1 powinna byc to liczba!" >&2
    usage
    exit 1
  fi
}
validate_port_list() {
  declare -a port_array=("${!1}")
  for ((i=0; i<${#port_array[@]}; i++)); do
    validate_port ${port_array[$i]}
  done
}
call_error() {
  echo "[ERROR]: niepoprawna wartosc: $1 powinniem byc to numer ip x.x.x.x gdzie x to liczby w przedziale od 0 do 255!" >&2
  usage
  exit 1
}
validate_ip () {
  declare -a split_ip=("${!1}")

  for i in {0..3}; do
    if [ "${split_ip[$i]}" -gt 255 ] || [ "${split_ip[$i]}" -lt 0 ]; then
      call_error ${split_ip[$i]}
    fi
  done
}
get_number_from_split_apart_ip() {
  declare -a split_apart_ip=("${!1}")
  local part_3=$((${split_apart_ip[3]}))
    local part_2=$((${split_apart_ip[2]} << 8))
    local part_1=$((${split_apart_ip[1]} << 16))
    local part_0=$((${split_apart_ip[0]} << 24))
    echo $(($part_0 + $part_1 + $part_2 + $part_3))
}
get_ip_from_number() {
    echo $(( ($1 & mask_3) >> 24 )).$(( ($1 & mask_2) >> 16 )).$(( ($1 & mask_1) >> 8 )).$(( $1 & mask_0 ))
}
ping_ip() {
  local first_attempt=$(nc -w 1 -zv $1 $2 2>&1)
  if  [[ $first_attempt == *'refused'* ]] || [[ $first_attempt == *'timed out'* ]]; then
    echo "brak polaczenia"
  else
    if [ $2 == $PORT_FTP ]; then
      local result=($(echo -e "QUIT" | nc $1 $2))
      result=$(echo "$result" | grep -oe '220.*')
      if [[ -z "$result" ]]; then
        echo $CONNECTION_OK
      else
        echo $result
      fi
    elif [[ $2 == $PORT_SSH ]]; then
      local result=$(echo -e "\n" | nc $1 $2)
      result=$(echo "$result" | grep -oe 'SSH.*')
      if [[ -z "$result" ]]; then
        echo $CONNECTION_OK
      else
        echo $result
      fi
    elif [[ $2 == $PORT_SMTP ]]; then
      local result=($(echo -e "QUIT" | nc $1 $2))
      result=$(echo "$result" | grep -oe '220.*')
      if [[ -z "$result" ]]; then
        echo $CONNECTION_OK
      else
        echo $result
      fi
    elif [[ $2 == $PORT_HTTP ]] || [[ $2 == $PORT_HTTPS ]]; then
      local result=$(echo -e "GET / HTTP/1.1\r\n\r\n" | nc $1 $2)
      if [[ -z "$result" ]]; then
        echo $CONNECTION_OK
      else

        result=$(echo "$result" | grep -oe 'Server: .*')
        echo $result
      fi
    else
      echo $CONNECTION_OK
    fi
  fi
}
ping_ip2() {
  exec 3<>/dev/tcp/$1/$2
  echo -e "$?" >&3
  cat <&3
  echo <&3
}
# #################################
# executions
# #################################
validate_usage $@
validate_string_input $1
validate_string_input $2
# get values from input
input_1=$1
input_2=$2
port_input=$3
IFS='.' ip_split_apart_1=(${input_1})
IFS='.' ip_split_apart_2=(${input_2})
IFS=',' ports=(${port_input})

validate_ip ip_split_apart_1[@]
validate_ip ip_split_apart_2[@]
validate_port_list ports[@]
ip_1=$(get_number_from_split_apart_ip ip_split_apart_1[@])
ip_2=$(get_number_from_split_apart_ip ip_split_apart_2[@])
#
starting_number=$ip_1
ending_number=$ip_2
if [ $ip_1 -gt $ip_2 ]; then
  starting_number=$ip_2
  ending_number=$ip_1
fi
for ((i=$starting_number; i<=$ending_number; i++)); do
  ip=$( get_ip_from_number $i)
  for ((j=0; j<${#ports[@]}; j++)); do
    # ping_ip $ip ${ports[$j]}
    echo "$ip:${ports[$j]} - $(ping_ip $ip ${ports[$j]} )"
  done
done
