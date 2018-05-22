#!/usr/bin/env bash
#

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
