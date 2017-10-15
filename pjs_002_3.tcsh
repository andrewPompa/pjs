#!/bin/csh -f
#jazowski_michal grupa 2
set is_help=false
set ADD='a'
set SUBTRACT='s'
set MULTIPLIY='m'
set DIVIDE='d'
set POWER='p'
set UNKNOWN='u'
set STEP_FORWARD=1
set STEP_BACKWORD=-1

foreach argument ( $argv )
  if ($argument == '-h' || $argument == '--help') then
    set is_help=true
  endif
end
if ($is_help == true) then
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
  exit 0
endif

set cond = `expr $1 : '^[+-]*[0-9][0-9]*$'`
set n = `echo $1 | wc -c`
@ n--
# $n
if ( $cond != $n ) then
  # echo "[ERROR]: niepoprawna wartosc: $1 powinna to byc liczba calkowita!" >&2
  echo "Blad"
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
  exit 1
endif
set cond = `expr $3 : '^[+-]*[0-9][0-9]*$'`
set n = `echo $2 | wc -c`
@ n--
if ! ( $cond != $n ) then
  # echo "[ERROR]: niepoprawna wartosc: $3 powinna to byc liczba calkowita!" >&2
  echo "Blad"
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
  exit 1
endif
# validate operator
set is_operator_valid=false
if  ($2 == $ADD ||  $2 == $SUBTRACT  ||  $2 == $MULTIPLIY  ||  $2 == $DIVIDE || $1 == $POWER)  then
  set is_operator_valid=true
endif

if  ($is_operator_valid == false) then
  echo "[ERROR]: niepoprawna wartosc operatora: $2"
  echo "Blad"
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
  exit 1
endif

alias sequence_forward "seq $1 $STEP_FORWARD $3"
alias sequence_backward="seq $1 $STEP_BACKWORD $2"
set vals=`sequence_forward`
set vals_length=$#vals
set first_line="/"
foreach i ( $vals )
  set first_line="$first_line $i |"
end
echo $first_line


set line
foreach j ( $vals )
  set line="$i| "
  foreach k ( $vals )
    set result
    if ( $2 == $ADD) then
      # @ result = 10 + 20
    else if ( $2 == $SUBTRACT) then
      set result='calc exp="($1)-($3)"'
    else if ( $2 ==  $MULTIPLIY) then
      set result='calc exp="($1)*($3)"'
    else if ( $2 == $DIVIDE) then
      if ( $3 -eq 0) then
        set result="N/A"
      else
        alias divide_operation 'bc <<< "scale=2;$1/$3"'
        set result=`divide_operation`
      endif
    else if ( $2 == $POWER) then
      if ( $1 -eq 0 && $3 -lt 0) then
        set result="N/A"
      else
        alias power_operation 'bc <<< "scale=2;$1^$2"'
        set result=`divide_operation`
      endif
    endif
    line="$line "
  end
  echo $line
end
