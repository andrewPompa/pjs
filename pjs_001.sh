#!/bin/bash
#jazowski_michal grupa 2

usage() {
  echo "Wyswietla informacje o obecnym uzytkowniku - login : Imie i Nazwisko"
  echo "Uzycie"
  echo "$0"
  echo "-h | --help Wyswietl pomoc"
  echo "-q | --quiet Tryb cichy"
}
rubbish_usage() {
  echo "Niezrozumiale polecenie"
  usage
}

validate_usage() {
  local is_help=false
  local is_quiet=false
  local is_rubbish=false
  while test $# -gt 0; do
    if [ $1 == -h ] || [ $1 == --help ]; then
      is_help=true
    elif [ $1 == -q ] || [ $1 == --quiet ]; then
      is_quiet=true
    elif [[ $1 == -* ]]; then
      is_rubbish=true
    fi
    shift
  done
  #echo "$is_help $is_quiet $is_rubbish
  if [ "$is_rubbish" == true ]; then
    #echo "rubbish with 1"
    rubbish_usage
    exit 1
  elif [ "$is_help" == true ]; then
    #echo "help with 0"
    usage
    exit 0
  elif [ "$is_quiet" == true ]; then
    #echo "quiet with 0"
    exit 0
  fi
}
get_and_show_user_info() {
  # pierwsza znaleziona metoda, ale nie zawsze jest zainstalowana
  # finger -l "$USER" | grep -e Name:
  user_name=$(getent passwd $USER | cut -d : -f 5 | cut -d , -f 1)
  if [ -z "$user_name" ]; then
    echo $USER
    exit 0
  fi
  echo "$USER : $user_name"
}
#=========
validate_usage $@
get_and_show_user_info
