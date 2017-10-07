#!/bin/csh -f
#jazowski_michal grupa 2
set is_help=false
set is_quiet=false
set is_rubbish=false


foreach argument ( $argv )
  if ($argument == '-h' || $argument == '--help') then
    set is_help=true
  else if  ($argument == '-q' || $argument == '--quiet') then
    set is_quiet=true
  else if ("$argument" =~ -*) then
    set is_rubbish = true
  endif
end
#  || `find_two_dash_option` != ""

#echo "$is_help $is_quiet $is_rubbish"
if ($is_rubbish == true) then
  echo "Niezrozumiale polecenie"
endif
if ($is_help == true || $is_rubbish == true) then
  echo "Wyswietla informacje o obecnym uzytkowniku - login : Imie i Nazwisko"
  echo "Uzycie"
  echo "pjs_001.csh"
  echo "-h | --help Wyswietl pomoc"
  echo "-q | --quiet Tryb cichy"
endif
if ($is_rubbish == true) then
  exit 1
endif
if ($is_help == true) then
  exit 0
endif
if ($is_quiet == true) then
  exit 0
endif

alias get_user_name "getent passwd $USER | cut -d : -f 5 | cut -d , -f 1"
set user_name = `get_user_name`
if ("$user_name" == "") then
  set user_name = $USER
endif
echo "$USER : $user_name"
