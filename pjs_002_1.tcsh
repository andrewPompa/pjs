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
  echo "Wyswietla tabliczke mnozenia, brak wymaganych argumentow"
  exit 0
endif

alias sequence_forward "seq 1 $STEP_FORWARD 10"
set vals=`sequence_forward`


set vals_length=$#vals
set first_line="/-"
foreach i ( $vals )
  set first_line="$first_line| $i "
end
echo "$first_line"


set line
foreach j ( $vals )
  if ($j < 10) then
    set line="$j-|"
  else
    set line="$j|"
  endif

  foreach k ( $vals )
    set result
    @ result = $j * $k
    if ( $result > 99) then
      set line="$line$result|"
    else if ( $result > 9) then
      set line="$line-$result|"
    else
      set line="$line-$result-|"
    endif
  end
  echo $line
end
