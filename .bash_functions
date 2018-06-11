#!/usr/bin/env bash
#

function removeDockerImages()
{
    local IMAGE=${1}
    local SKIP=${2}

    if [ -z "${IMAGE}" ]
        echo "Usage: $0 <repository name> [<# of image to skip>]"

        exit -1
    fi

    if [ -z "${SKIP}" ]
        SKIP=1
    fi

    docker images | awk '{ if (NR > 1 && $1 == "${IMAGE}") print }' | awk '{ if (NR > ${SKIP}) print $3 }' | xargs docker image rm
}

function sshTunnel()
{
    if [ $# -lt 3 ]
    then
        echo "Usage: $0 <local port> [<username>@]<remote host> <remote port>"

        exit -1
    fi

    echo -e "\nTunnelling \"localhost:${1}\" to \"${2}:${3}\"..."

    ssh -NL ${1}:localhost:${3} ${2}
}

# Useful functions (if you are in Bash under WSL)
#
function getWindowsFriendlyRealPath()
{
    local TARGET="${1}"

    if [ -z "${TARGET}" ]
        TARGET="."
    fi

    local REALPATH="$(realpath ${TARGET})"
    REALPATH="${REALPATH#/mnt}"

    echo ${REALPATH}
}
