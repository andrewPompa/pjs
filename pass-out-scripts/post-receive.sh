#!/bin/bash
#
# Skrypt bazuje na: https://gist.github.com/thomasfr/9691385
#
usage() {
  echo "Git hook na push do wyszczególnionego branch'a"
  echo "Uruchamia skrypt który odpowiedzialny za zbudowanie  i uruchomienie aplikacji"
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

REPO_DIRECTORY="/home/git/test-repo.git"
BRANCH="develop"
BUILD_SCRIPT_PATH=/home/git/build.sh
FRONTEND_REPO_DIRECTORY=/home/git/astro-frontend.git/
BACKEND_REPO_DIRECTORY=/home/git/astro-backend.git/
LOGS_PATH=/home/git/test-ci/build.log
###########################################################################################

while read oldrev newrev refname
do
    export DEPLOY_BRANCH=$(git rev-parse --symbolic --abbrev-ref $refname)
    export DEPLOY_OLDREV="$oldrev"
    export DEPLOY_NEWREV="$newrev"
    export DEPLOY_REFNAME="$refname"

    if [ "$DEPLOY_NEWREV" = "0000000000000000000000000000000000000000" ]; then
        echo "[ERROR] Ta rewizja nie istnieje!"
        exit 1
    fi

    if [ ! -z "${BRANCH}" ]; then
        if [ "${BRANCH}" != "$DEPLOY_BRANCH" ]; then
            echo "Oczekuję na branch '$DEPLOY_BRANCH' aplikacja nie będzie uruchomiona."
            exit 1
        fi
    fi
    ${BUILD_SCRIPT_PATH} ${FRONTEND_REPO_DIRECTORY} ${BACKEND_REPO_DIRECTORY} ${BRANCH}  > ${LOGS_PATH} 2>&1 &
done

echo
exit 0