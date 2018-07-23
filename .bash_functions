#!/usr/bin/env bash
#

function removeDockerImages()
{
    local IMAGE=${1}
    local SKIP=${2}

    if [ -z "${IMAGE}" ]
    then
        echo "Usage: removeDockerImages <repository name> [<# of image to skip> | 1]"
    else
        if [ -z "${SKIP}" ]
        then
            SKIP=1
        fi

        docker images | awk -v IMAGE="${IMAGE}" '{ if (NR > 1 && $1 == IMAGE) print }' | awk -v SKIP=${SKIP} '{ if (NR > SKIP) print $3 }' | xargs docker image rm
    fi
}

function sshTunnel()
{
    if [ ${#} -lt 3 ]
    then
        echo "Usage: sshTunnel <local port> [<username>@]<remote host> <remote port>"
    else
        echo -e "\nTunnelling \"localhost:${1}\" to \"${2}:${3}\"..."

        ssh -NL ${1}:localhost:${3} ${2}
    fi
}

function tarCompress()
{
    if [ ${#} -lt 2 ]
    then
        echo "Usage: tarCompress <archive name> <file or directory to compress>"
    else
        tar -czvf "${1}" "${2}"
    fi
}
function tarExtract()
{
    if [ ${#} -lt 1 ]
    then
        echo "Usage: tarExtract <archive name> [<directory where extract archive> | .]"
    else
        local EXTRACT_PATH="${2}"

        if [ -z "${EXTRACT_PATH}" ]
        then
            EXTRACT_PATH="."
        fi

        tar -xzvf "${1}" -C "${EXTRACT_PATH}"
    fi
}

#
# Useful functions (if you are in Bash under WSL)
#
function getWindowsFriendlyRealPath()
{
    local TARGET="${1}"

    if [ -z "${TARGET}" ]
    then
        TARGET="."
    fi

    local REALPATH="$(realpath ${TARGET})"
    REALPATH="${REALPATH#/mnt}"

    echo "${REALPATH}"
}
