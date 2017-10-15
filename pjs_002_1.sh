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
  echo "Wyswietla tabliczke mnozenia, brak wymaganych argumentow"
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


draw_table_and_do_mathematical_operation() {
  local vals=($(seq $1 $STEP_FORWARD $2))

  if [ "$1" -gt "$2" ]; then
    vals=($(seq $1 $STEP_BACKWORD $2))
  fi
  local vals_length=${#vals[@]}

  local first_line=$(echo -e \\-)
  # If subscript is @ or *, the word expands to all members of name.
  # By prefixing # to variable you will find length of an array
  for ((i=0; i<=$vals_length; i++)); do
    first_line+=$(echo -e "| ${vals[$i]} ")
  done
  echo $first_line

  local line
  for ((i=0; i<$vals_length; i++)); do
    line=""
    if [ ${vals[$i]} -lt 10 ]; then
      line+=$(echo -e "${vals[$i]} |")
    else
      line+=$(echo -e "${vals[$i]}|")
    fi
    for ((j=0; j<$vals_length; j++)); do
      local result=$(do_mathematical_operation ${vals[$i]} ${vals[$j]} $3)
      if [ $result -gt 99 ]; then
        line+=$(echo "$result|")
      elif [ $result -gt 9 ]; then
        line+=$(echo "$result |")
      else
        line+=$(echo "-$result-|")
      fi
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
num_1=1
num_2=10
operator=$MULTIPLIY
draw_table_and_do_mathematical_operation $num_1 $num_2 $operator
