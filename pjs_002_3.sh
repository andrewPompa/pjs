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
  # local number_without_zero=$1
  # if [ $1 -gt 0 ]; then
  # echo "wieksze"
  # else
  # echo "mniejsze"
  # fi
  # $(echo $1 | grep -oe [1-9][0-9]*)
  local number=$(echo $1 | cut -d + -f 2 |  cut -d . -f 1)
  echo $number
}
draw_table_and_do_mathematical_operation() {
  local vals=($(seq $1 $STEP $2))
  echo ${#vals[@]}

  for((k=0; k<${#vals[@]}; k++)) {
    echo ${vals[$k]}
  }
  # printf "%s\n" "${vals[@]}"

  local starting_number=$1
  local ending_number=$2
  if [ "$1" -gt "$2" ]; then
    starting_number=$2
    ending_number=$1
  fi
  # echo "zaczynam od: $starting_number"
  local first_line=$(echo -e \\)
  for ((i=$starting_number; i<=$ending_number; i++)); do
    first_line+=$(echo -e "\t$i")
  done
  echo $first_line

  local line
  for ((i=$starting_number; i<=$ending_number; i++)); do
    local line=$(echo "$i ")
    for ((j=$starting_number; j<=$ending_number; j++)); do
      local result=$(do_mathematical_operation $i $j $3)
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
      echo $(( $1 / $2 ))
    fi
  elif [[ $3 == $POWER ]]; then
    echo $("$1^$2" | bc)
  fi
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
draw_table_and_do_mathematical_operation $num_1 $num_2 $operator
