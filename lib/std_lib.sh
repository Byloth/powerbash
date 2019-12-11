#!/usr/bin/env bash
#

function getRealPath()
{
    local REALPATH="$(realpath "${1}")"
    REALPATH="${REALPATH#/mnt}"

    echo "${REALPATH}"
}

function loadFile()
{
    local FILE_DIR="$(dirname "${0}")"

    source "${FILE_DIR}/${1}"
}
