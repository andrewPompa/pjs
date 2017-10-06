#!/bin/bash
#jazowski_michal

usage() {
  echo "Wyswietla informacje o obecnym uzytkowniku"
  echo "Uzycie"
  echo "$0"
  echo "-h | --help Wyswietl pomoc"
  echo "-q | --quiet Tryb cichy"
}

validate_usage() {
  local is_help=false
  local is_quiet=false
  local is_rubbish=false
  while test $# -gt 0; do
    case "$1" in
      -h|--help)
        is_help=true
      ;;
      -q|--quiet)
        is_quiet=true
      ;;
      *)
        is_rubbish=true
      ;;
    esac
    shift
  done
  #echo "$is_help $is_quiet $is_rubbish"

  if [ "$is_help" = true ]; then
    if [ "$is_rubbish" = false ]; then
      #echo "help with 0"
      usage
      exit 0
    else
      #echo "help with 1"
      usage
      exit 1
    fi
  fi
  if [ "$is_quiet" = true ]; then
    #echo "quiet with 0"
    exit 0
  fi
  if [ "$is_rubbish" = true ]; then
    #echo "rubbish with 1"
    usage
    exit 1
  fi

}
get_and_show_user_info() {
  # pierwsza znaleziona metoda, ale nie zawsze jest zainstalowana
  # finger -l "$USER" | grep -e Name:
  user_name=$(getent passwd $USER | cut -d : -f 5 a | cut -d , -f 1)
  if [ -z "$user_name" ]; then
    user_name=$(echo $USER)
  fi
  echo "uzytkownik: $user_name"
}
#=========
validate_usage $@
get_and_show_user_info
