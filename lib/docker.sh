#!/usr/bin/env bash
#

source "$(dirname ${0})/../lib/std_output.sh"

function getLastImageVersion()
{
    docker images | grep ^${1} | awk '{ if (NR == 1) print $2 }'
}

function isDockerRunning()
{
    docker ps &> /dev/null
    local IS_RUNNING=$((1 - ${?}))

    echo ${IS_RUNNING}
}

function dockerFind()
{
    docker ps | awk '{ if (NR > 1) print $NF }' | grep "^${1}$"
}

#
# function dockerRun()
# {
#     [...]
# }
#

function dockerStop()
{
    if [ "$(docker stop ${1})" == "${1}" ]
    then
        echo "$(success "OK!")"
    else
        echo "$(error "Something went wrong!")"

        exit 4
    fi
}

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
