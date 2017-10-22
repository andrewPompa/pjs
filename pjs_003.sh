#!/bin/bash
#jazowski_michal grupa 2

mask_0=$((0x000000FF))
mask_1=$((0x0000FF00))
mask_2=$((0x00FF0000))
mask_3=$((0xFF000000))

usage() {
  echo "Sprawdza dostepnosc IP w przedziale od IP_1 do IP_2 wlacznie"
  echo "Uzycie"
  echo "$0 IP_1 IP_2"
  echo "IP_1 IP_2 - adres ip x.x.x.x"
  echo "Zwraca"
  echo "IP - zywy/martwy"
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
    error $1
  fi
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
	if ! ping -c 1 -w 1 "$1" &>/dev/null ; then
		echo "zywy"
	else
		echo "martwy"
	fi
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
IFS='.' ip_split_apart_1=(${input_1})
IFS='.' ip_split_apart_2=(${input_2})

validate_ip ip_split_apart_1[@]
validate_ip ip_split_apart_2[@]
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
    echo "$ip - $(ping_ip $ip)"
done
