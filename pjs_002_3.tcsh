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
if  ($2 == $ADD ||  $2 == $SUBTRACT  ||  $2 == $MULTIPLIY  ||  $2 == $DIVIDE || $2 == $POWER)  then
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
alias sequence_backward "seq $1 $STEP_BACKWORD $3"
if ( $1 > $3 ) then
  set vals=`sequence_backward`
else
  set vals=`sequence_forward`
endif
set vals_length=$#vals
set first_line="/"
foreach i ( $vals )
  set first_line="$first_line $i |"
end
echo $first_line


set line
foreach j ( $vals )
  set line="$j| "
  foreach k ( $vals )
    set result
    if ( $2 == $ADD) then
      @ result = $j + $k
    else if ( $2 == $SUBTRACT) then
      @ result = $j - $k
    else if ( $2 ==  $MULTIPLIY) then
      @ result = $j * $k
    else if ( $2 == $DIVIDE) then
      if ( $3 == 0) then
        set result="N/A"
      else
        alias divide_operation 'echo "scale=2;$j/$k" | bc'
        set result=`divide_operation`
      endif
    else if ( $2 == $POWER) then
     if ( $j == 0 && $k < 0) then
       set result="N/A"
     else
       alias power_operation 'echo "scale=5;$j^$k" | bc'
       set result=`power_operation`
     endif
    endif
    set line="$line $result"
  end
  echo $line
end
