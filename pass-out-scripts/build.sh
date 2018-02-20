#!/bin/bash
usage() {
  echo "Przykładowy skrypt uruchamiany przez git hook'a. Jest to namiastka narzędzia do Continuous Integration i Continuous Deployment"
  echo "Pobiera z repozytorium i buduje, najpierw, frontend aplikacji (NodeJS)."
  echo "Następnie pliki wynikowe przenoszone są do odpowiedniego katalogu dla pobranego z repo backendu (Spring Boot i maven)"
  echo "Przed uruchomieniem aplikacji zabijany jest proces z wcześniejszą wersją"
  echo "W tak przygotowanym środowisku uruchamiana jest aplikacja po świeżym push'u"
  echo "Użycie:"
  echo "$0 sciezka-do-repo-frontendu sciezka-do-repo-backendu nazwa-brancha"
  echo "sciezka-do-repo-frontendu ścieżka do repozytorium z którego zostanie pobrany frontend aplikacji"
  echo "sciezka-do-repo-backend ścieżka do repozytorium z którego zostanie pobrany backend aplikacji"
  echo "nazwa-brancha branch z którego zostanie pobrany kod, taki sam dla obu aplikacji"
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

validate_usage $@

if [ "$#" -ne 3 ]; then
    echo "[ERROR] Niepoprawna ilość argumentów wymagano 3!" >&2
    exit 1
fi

USER_NAME=git
WORKING_DIRECTORY=/home/${USER_NAME}/test-ci/
FRONTEND_DIRECTORY=frontend
BACKEND_DIRECTORY=backend

FRONTEND_REPO_PATH=$1
BACKEND_REPO_PATH=$2
BRANCH_NAME=$3

#----> sprawdzenie folderów
if [ ! -d "$WORKING_DIRECTORY" ]; then
    mkdir ${WORKING_DIRECTORY}
fi
cd ${WORKING_DIRECTORY}
if [ ! -d "$BACKEND_DIRECTORY" ]; then
    mkdir ${BACKEND_DIRECTORY}
fi
rm -rf ${BACKEND_DIRECTORY}
git clone -b ${BRANCH_NAME} ${BACKEND_REPO_PATH} ${BACKEND_DIRECTORY}
if [ ! -d "$FRONTEND_DIRECTORY" ]; then
    mkdir ${FRONTEND_DIRECTORY}
fi
rm -rf ${FRONTEND_DIRECTORY}
git clone -b ${BRANCH_NAME} ${FRONTEND_REPO_PATH} ${FRONTEND_DIRECTORY}
#----> build frontendu
cd ${FRONTEND_DIRECTORY}
npm install
ng build --prod
#----> kopiowanie i build backendu
cd ../${BACKEND_DIRECTORY}
if [ ! -d "src/main/resources/public/" ]; then
    mkdir src/main/resources/public/
fi
cp ../${FRONTEND_DIRECTORY}/dist/* src/main/resources/public/
#----> sprawdzenie czy działa już serwer
if [ ! -f ../pid.txt ]; then
    touch pid.txt
else
    kill -9 $(cat ../pid.txt)
fi
mvn spring-boot:run &
echo $! > ../pid.txt