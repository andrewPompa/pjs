#!/bin/bash
#jazowski_michal grupa 2

ADD='a'
SUBTRACT='s'
MULTIPLIY='m'
DIVIDE='d'
POWER='p'
UNKNOWN='u'
STEP_FORWARD=1
STEP_BACKWORD=-1

usage() {
  echo "Wykonuje operacje na liczbach calkowitych"
  echo "Uzycie"
  echo "$0 n1 o n2"
  echo "n1 n2 - liczby calkowite"
  echo "o - operator matematyczny, mozliwe opcje:"
  echo " $ADD - dodawanie"
  echo " $SUBTRACT - odejmowanie"
  echo " $MULTIPLIY - mnozenie"
  echo " $DIVIDE - dzielenie"
  echo " $POWER - potegowanie"
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

validate_numbers() {
  validate_number $1
  validate_number $2
}
validate_number() {
  local int_regexp='^[-+]?[0-9]+(\.0)?$'
  if ! [[ $1 =~ $int_regexp ]] ; then
    echo "[ERROR]: niepoprawna wartosc: $1 powinna to byc liczba calkowita!" >&2
    usage
    exit 1
  fi
}
validate_operator() {
  local operator=$(get_operator $1)
  if [ $operator == $UNKNOWN ]; then
    echo "[ERROR]: niepoprawna wartosc operatora: $1" >&2
    usage
    exit 1
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
  local number=$(echo $1 | cut -d + -f 2 |  cut -d . -f 1)
  echo $number
}
draw_table_and_do_mathematical_operation() {
  local vals=($(seq $1 $STEP_FORWARD $2))

  if [ "$1" -gt "$2" ]; then
    vals=($(seq $1 $STEP_BACKWORD $2))
  fi
  local vals_length=${#vals[@]}

  local first_line=$(echo -e \\)
  # If subscript is @ or *, the word expands to all members of name.
  # By prefixing # to variable you will find length of an array
  for ((i=0; i<=$vals_length; i++)); do
    first_line+=$(echo -e "| ${vals[$i]} ")
  done
  echo $first_line

  local line
  for ((i=0; i<$vals_length; i++)); do
    local line=$(echo "${vals[$i]}|")
    for ((j=0; j<$vals_length; j++)); do
      local result=$(do_mathematical_operation ${vals[$i]} ${vals[$j]} $3)
      line+=$(echo "$result ")
    done
    echo $line
  done
}
do_mathematical_operation() {
  if [[ $3 == $ADD ]]; then
    echo $(( $1 + $2 ))
  elif [[ $3 == $SUBTRACT ]]; then
    echo $(( $1 - $2 ))
  elif [[ $3 ==  $MULTIPLIY ]]; then
    echo $(( $1 * $2 ))
  elif [[ $3 == $DIVIDE ]]; then
    if [[ $2 -eq 0 ]]; then
      echo "N/A"
    else
      echo $(bc <<< "scale=5;$1/$2")
    fi
  elif [[ $3 == $POWER ]]; then
    if [[ $1 -eq 0 ]] && [[ $2 -lt 0 ]]; then
      echo "N/A"
    else
      echo $(bc <<< "scale=5;$1^$2")
    fi
  fi
}
# #################################
# executions
# #################################
validate_usage $@
validate_numbers $1 $3
num_1=$(get_number $1)
num_2=$(get_number $3)
validate_operator $2
operator=$(get_operator $2)
draw_table_and_do_mathematical_operation $num_1 $num_2 $operator
