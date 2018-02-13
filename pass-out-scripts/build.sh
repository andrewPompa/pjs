#!/bin/bash
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