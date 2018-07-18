#!/usr/bin/env bash
#

readonly CONFIGS_FILE="odoo.conf"

readonly DEFAULT_PORT="8069"
readonly DEFAULT_PGHOST="10.0.75.1"
readonly DEFAULT_PGPORT="5432"
readonly DEFAULT_PGUSER="root"
readonly DEFAULT_PGPASSWORD=""
readonly DEFAULT_ADMIN_PASSWD="admin00"

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
        ADMIN_PASSWD="${LAST_ADMIN_PASSWD}"
    fi
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
    docker ps | awk '{ if (NR > 1) print $NF }' | grep -w ${1}
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
               ${IMAGE}:${VERSION} ${@} --dev all
}
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

loadConfigurations "${CONFIGS_FILE}"
loadDefaults

checkConfigurations

echo -e "\n  I'm going to start a new Odoo instance..."
echo -e "   └ Container name: $(info "${NAME}")"

if [ "${VERSION}" != "${LAST_VERSION}" ]
then
    echo -e "   └ Image tag: $(info "${IMAGE}"):$(warning "${VERSION}")"
else
    echo -e "   └ Image tag: $(info "${IMAGE}"):$(info "${VERSION}")"
fi

if [ -n "$(dockerFind "${NAME}")" ]
then
    echo -e "\n   ------------------------------"
    echo -e "\n  $(warning "WARNING"): There is already another Docker"
    echo -e "   container running with the same name...\n"
    read -p "  Do you wish to stop it? [Y]: " ANSWER

    if [ -z "${ANSWER}" ] || [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        echo -e "   └ I'm stopping it... \c"

        dockerStop "${NAME}"
    else
        echo -e "   └ Ok... No problem!"

        exit 0
    fi
fi

echo -e "\n  Start logging..."
echo -e " ------------------------------\n"

dockerRun ${@}
