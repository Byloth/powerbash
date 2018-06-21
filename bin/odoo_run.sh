#!/usr/bin/env bash
#

function success()
{
    echo -e "\033[0;32m${1}\033[0m"
}
function info()
{
    echo -e "\033[0;36m${1}\033[0m"
}
function warning()
{
    echo -e "\033[4;33m${1}\033[0m"
}
function error()
{
    echo -e "\033[4;31m${1}\033[0m"
}

function getRealPath()
{
    local REALPATH="$(realpath .)"
    REALPATH="${REALPATH#/mnt}"

    echo ${REALPATH}
}

function getLastImageVersion()
{
    docker images | grep ^${IMAGE} | awk '{ if (NR == 1) print $2 }'
}

function isDockerRunning()
{
    docker ps &> /dev/null
    local IS_RUNNING=$((1 - ${?}))

    echo ${IS_RUNNING}
}

function dockerFind()
{
    docker ps | awk '{ if (NR > 1) print $NF }' | grep -w ${NAME}
}
function dockerRun()
{
    local PWD="$(getRealPath)"

    docker run --rm -it \
               --name=${NAME} \
               -p ${PORT}:8069 \
               -e PGHOST=${PGHOST} \
               -e PGPORT=${PGPORT} \
               -e PGUSER=${PGUSER} \
               -e PGPASSWORD=${PGPASSWORD} \
               -e ADMIN_PASSWD=${ADMIN_PASSWD} \
               -v ${DATA_VOLUME}:/var/lib/odoo \
               -v ${PWD}/addons:/opt/odoo/extra-addons/custom:ro \
               ${IMAGE}:${RUNNING_VERSION} ${@} --dev reload
}
function dockerStop()
{
    if [ "$(docker stop ${NAME})" == "${NAME}" ]
    then
        echo "$(success "OK!")"
    else
        echo "$(error "Something went wrong!")"

        exit 3
    fi
}

clear

if [ $(isDockerRunning) -eq 0 ]
then
    echo -e "\n  $(warning "WARNING"): \c"

    if [ -n "${DOCKER_HOST}" ]
    then
        echo -e "can't connect to the Docker"
        echo -e "   daemon at $(info "tcp://${DOCKER_HOST}")."
    else
        echo -e "can't connect to the Docker daemon."
    fi

    echo -e "\n  Is the Docker daemon running?"

    exit -1
fi

CONFIGS_FILE="configs.sh"

if [ -f ./${CONFIGS_FILE} ]
then
    source ./${CONFIGS_FILE}
else
    echo "$(error "Missing instance configuration file: \"${CONFIGS_FILE}\"!")"

    exit 1
fi

echo -e "\n  I'm going to start a new Odoo instance..."
echo -e "   └ Container name: $(info "${NAME}")"

LAST_VERSION="$(getLastImageVersion)"

if [ -n "${VERSION}" ]
then
    RUNNING_VERSION="${VERSION}"
else
    RUNNING_VERSION="${LAST_VERSION}"
fi

if [ "${RUNNING_VERSION}" != "${LAST_VERSION}" ]
then
    echo -e "   └ Image tag: $(info "${IMAGE}"):$(warning "${RUNNING_VERSION}")"
else
    echo -e "   └ Image tag: $(info "${IMAGE}:${RUNNING_VERSION}")"
fi

if [ -n "$(dockerFind)" ]
then
    echo -e "\n   ------------------------------"
    echo -e "\n  $(warning "WARNING"): There is already another Docker"
    echo -e "   container running with the same name...\n"
    read -p "  Do you wish to stop it? [Y]: " ANSWER

    if [ -z "${ANSWER}" ] || [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        echo -e "   └ I'm stopping it... \c"

        dockerStop
    else
        echo -e "   └ Ok... No problem!"

        exit 2
    fi
fi

echo -e "\n  Start logging..."
echo -e " ------------------------------\n"

dockerRun ${@}
