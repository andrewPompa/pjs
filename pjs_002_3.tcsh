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
echo -e The gif files

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

# set number=123
# [-+]?[0-9]+(\.0)?
# alias check_number "echo $number | grep -Eq ^[0-9]+$"
# set result=`check_number`
# echo $result
# if ! ( $1 =~ !^[-+]?[0-9]+(\.0)?!$ ) then
#   echo "[ERROR]: niepoprawna wartosc: $1 powinna to byc liczba calkowita!" >&2
#   echo "Wykonuje operacje na liczbach calkowitych"
#   echo "Uzycie"
#   echo "$0 n1 o n2"
#   echo "n1 n2 - liczby calkowite"
#   echo "o - operator matematyczny, mozliwe opcje:"
#   echo " $ADD - dodawanie"
#   echo " $SUBTRACT - odejmowanie"
#   echo " $MULTIPLIY - mnozenie"
#   echo " $DIVIDE - dzielenie"
#   echo " $POWER - potegowanie"
#   exit 1
# endif
# if ! ( $2 =~ $int_regexp ) then
#   echo "[ERROR]: niepoprawna wartosc: $2 powinna to byc liczba calkowita!" >&2
#   echo "Wykonuje operacje na liczbach calkowitych"
#   echo "Uzycie"
#   echo "$0 n1 o n2"
#   echo "n1 n2 - liczby calkowite"
#   echo "o - operator matematyczny, mozliwe opcje:"
#   echo " $ADD - dodawanie"
#   echo " $SUBTRACT - odejmowanie"
#   echo " $MULTIPLIY - mnozenie"
#   echo " $DIVIDE - dzielenie"
#   echo " $POWER - potegowanie"
#   exit 1
# endif
