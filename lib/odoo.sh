#!/usr/bin/env bash
#

source "$(dirname ${0})/../lib/std_lib.sh"

loadFile "../lib/std_output.sh"
loadFile "../lib/postgresql.sh"
loadFile "../lib/docker.sh"

readonly CONFIGS_FILE="odoo.conf"

readonly DEFAULT_PORT="8069"
readonly DEFAULT_ADMIN_PASSWD="admin00"

function checkConfigurations()
{
    if [ -z "${NAME}" ]
    then
        echo -e "\n  $(error "Missing key \"name\" in configuration file!")"

        exit 2
    fi

    if [ -z "${IMAGE}" ]
    then
        echo -e "\n  $(error "Missing key \"image\" in configuration file!")"

        exit 3
    fi
}

function exportConfigurations()
{
    export PGHOST
    export PGPORT
    export PGUSER
    export PGPASSWORD
}

function loadConfigurations()
{
    if [ -f ./${1} ]
    then
        while IFS='' read -r LINE || [[ -n "${LINE}" ]]
        do
            PROPERTY="$(echo "${LINE}" | cut -d '#' -f 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

            if [ -n "${PROPERTY}" ]
            then
                KEY="$(echo "${PROPERTY}" | awk '{ print $1 }')"
                VALUE="$(echo "${PROPERTY}" | awk '{ print $3 }')"

                case "${KEY}" in
                "name")
                    NAME="${VALUE}"
                    ;;
                "volume" | "data_volume")
                    DATA_VOLUME="${VALUE}"
                    ;;
                "port")
                    PORT="${VALUE}"
                    ;;
                "image")
                    IMAGE="${VALUE}"
                    ;;
                "version")
                    VERSION="${VALUE}"
                    ;;
                "pghost")
                    PGHOST="${VALUE}"
                    ;;
                "pgport")
                    PGPORT="${VALUE}"
                    ;;
                "pguser")
                    PGUSER="${VALUE}"
                    ;;
                "pgpass" | "pgpassword")
                    PGPASSWORD="${VALUE}"
                    ;;
                "admin_pass" | "admin_passwd")
                    ADMIN_PASSWD="${VALUE}"
                    ;;
                esac
            fi

        done < "./${1}"
    else
        echo -e "\n  $(error "Missing instance configuration file: \"${1}\"!")"

        exit 1
    fi
}

function loadDefaults()
{
    LAST_VERSION="$(getLastImageVersion "${IMAGE}")"

    if [ -z "${DATA_VOLUME}" ]
    then
        DATA_VOLUME="${NAME}_data"
    fi

    if [ -z "${PORT}" ]
    then
        PORT="${DEFAULT_PORT}"
    fi

    if [ -z "${VERSION}" ]
    then
        VERSION="${LAST_VERSION}"
    fi

    if [ -z "${PGHOST}" ]
    then
        PGHOST="${DEFAULT_PGHOST}"
    fi
    if [ -z "${PGPORT}" ]
    then
        PGPORT="${DEFAULT_PGPORT}"
    fi
    if [ -z "${PGUSER}" ]
    then
        PGUSER="${DEFAULT_PGUSER}"
    fi
    if [ -z "${PGPASSWORD}" ]
    then
        PGPASSWORD="${DEFAULT_PGPASSWORD}"
    fi

    if [ -z "${ADMIN_PASSWD}" ]
    then
        ADMIN_PASSWD="${DEFAULT_ADMIN_PASSWD}"
    fi
}

function odooRun()
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
               ${IMAGE}:${VERSION} ${@}
}

loadConfigurations "${CONFIGS_FILE}"
loadDefaults

checkConfigurations
exportConfigurations
