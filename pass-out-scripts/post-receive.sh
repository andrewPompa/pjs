#!/bin/bash
#
# Script based on: https://gist.github.com/thomasfr/9691385
#


export DEPLOY_APP_NAME=`whoami`
export DEPLOY_ROOT="${HOME}/work"
export DEPLOY_ALLOWED_BRANCH="develop"
REPO_DIRECTORY="/home/git/test-repo.git"
BRANCH="origin/develop"

# You could use this to do a backup before updating to be able to do a quick rollback.
# If you need this just delete the comment and modify to your needs
#PRE_UPDATE_CMD='cd ${DEPLOY_ROOT} && backup.sh'

# Use this to do update tasks and maybe service restarts
# If you need this just delete the comment and modify to your needs
#POST_UPDATE_CMD='cd ${DEPLOY_ROOT} && make update'

###########################################################################################

export GIT_DIR="$(cd $(dirname $(dirname $0));pwd)"
export GIT_WORK_TREE="${DEPLOY_ROOT}"
IP="$(ip addr show eth0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"

echo "githook: $(date): Welcome to '$(hostname -f)' (${IP})"
echo

# Make sure directory exists. Maybe its deployed for the first time.
mkdir -p "${DEPLOY_ROOT}"

# Loop, because it is possible to push more than one branch at a time. (git push --all)
while read oldrev newrev refname
do

    export DEPLOY_BRANCH=$(git rev-parse --symbolic --abbrev-ref $refname)
    export DEPLOY_OLDREV="$oldrev"
    export DEPLOY_NEWREV="$newrev"
    export DEPLOY_REFNAME="$refname"

    if [ "$DEPLOY_NEWREV" = "0000000000000000000000000000000000000000" ]; then
        echo "githook: This ref has been deleted"
        exit 1
    fi

    if [ ! -z "${DEPLOY_ALLOWED_BRANCH}" ]; then
        if [ "${DEPLOY_ALLOWED_BRANCH}" != "$DEPLOY_BRANCH" ]; then
            echo "githook: Branch '$DEPLOY_BRANCH' of '${DEPLOY_APP_NAME}' application will not be deployed. Exiting."
            exit 1
        fi
    fi

    if [ ! -z "${PRE_UPDATE_CMD}" ]; then
       echo
       echo "githook: PRE UPDATE (CMD: '${PRE_UPDATE_CMD}'):"
       eval $PRE_UPDATE_CMD || exit 1
    fi

    # Make sure GIT_DIR and GIT_WORK_TREE is correctly set and 'export'ed. Otherwhise
    # these two environment variables could also be passed as parameters to the git cli
    echo "githook: I will deploy '${DEPLOY_BRANCH}' branch of the '${DEPLOY_APP_NAME}' project to '${DEPLOY_ROOT}'"
    git checkout -f "${DEPLOY_BRANCH}" || exit 1
    git reset --hard "$DEPLOY_NEWREV" || exit 1

    if [ ! -z "${POST_UPDATE_CMD}" ]; then
       echo
       echo "githook: POST UPDATE (CMD: '${POST_UPDATE_CMD}'):"
       eval $POST_UPDATE_CMD || exit 1
    fi

    /home/git/build.sh /home/git/astro-frontend.git/ /home/git/astro-backend.git/ develop  > /home/git/test-ci/build.log 2>&1 &
done

echo
echo "githook: $(date): See you soon at '$(hostname -f)' (${IP})"
exit 0