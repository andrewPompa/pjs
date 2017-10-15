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
  echo "Wyswietla tabliczke mnozenia, dla przedzialu liczb"
  echo "$0 n1 n2"
  echo "n1, n2 liczby calkowite"
  exit 0
endif

set cond = `expr $1 : '^[+-]*[0-9][0-9]*$'`
set n = `echo $1 | wc -c`
@ n--
# $n
if ( $cond != $n ) then
  echo "[ERROR]: niepoprawna wartosc: $1 powinna to byc liczba calkowita!"
  echo "Wyswietla tabliczke mnozenia, dla przedzialu liczb"
  echo "$0 n1 n2"
  echo "n1, n2 liczby calkowite"
  exit 1
endif
set cond = `expr $3 : '^[+-]*[0-9][0-9]*$'`
set n = `echo $2 | wc -c`
@ n--
if ! ( $cond != $n ) then
  echo "[ERROR]: niepoprawna wartosc: $2 powinna to byc liczba calkowita!"
  echo "Wyswietla tabliczke mnozenia, dla przedzialu liczb"
  echo "$0 n1 n2"
  echo "n1, n2 liczby calkowite"
  exit 1
endif
# validate operator
alias sequence_forward "seq $1 $STEP_FORWARD $2"
alias sequence_backward "seq $1 $STEP_BACKWORD $2"
if ( $1 > $2 ) then
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
    @ result = $j * $k
    set line="$line $result"
  end
  echo $line
end
