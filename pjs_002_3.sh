#!/bin/bash
#jazowski_michal grupa 2

ADD='a'
SUBTRACT='s'
MULTIPLIY='m'
DIVIDE='d'
POWER='p'
UNKNOWN='u'

usage() {
  echo "Wykonuje operacje na liczbach calkowitych"
  echo "Uzycie"
  echo "$0 n1 o n2"
  echo "n1 n2 - liczby calkowite"
  echo "o - operator mozliwy w formacie:"
  echo " $ADD - dodawanie"
  echo " $SUBTRACT - odejmowanie"
  echo " $MULTIPLIY - mnozenie"
  echo " $DIVIDE - dzielenie"
  echo " $POWER - potegowanie"
}
validate_numbers() {
	validate_number $1
	validate_number $2
}
validate_number() {
	local int_regexp='^[-+]?[0-9]+(\.0)?$'
	if ! [[ $1 =~ $int_regexp ]] ; then
  	echo "[ERROR]: niepoprawna wartosc: $1 powinna to byc liczba calkowita!" >&2; exit 1
	fi
}
validate_operator() {
	local operator=$(get_operator $1)
	if [ $operator == $UNKNOWN ]; then
		echo "[ERROR]: niepoprawna wartosc operatora: $1" >&2; exit 1
	fi
}
get_operator() {
	if [ $1 == $ADD ] || [ $1 == $SUBTRACT ] || [ $1 == $MULTIPLIY ] || [ $1 == $DIVIDE ] || [ $1 == $POWER ]; then
		echo $1
	else
		echo $UNKNOWN
	fi
}
get_number() {
	#check what going on with 000000
	echo $(echo $1 | cut -d + -f 2 |  cut -d . -f 1)
}

# executions
#usage
validate_numbers $1 $3
num_1=$(get_number $1)
num_2=$(get_number $3)
validate_operator $2
echo $num_1
echo $num_2
operator=$(get_operator $2)
echo $operator
