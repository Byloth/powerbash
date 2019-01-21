#!/usr/bin/env bash
#

function getIpAddresses()
{
    ifconfig | grep "inet " | awk '{ print $2 }'
}

function odooChangePassword()
{
    echo ""
    read -s -p "New password: " NEW_PASSWD
    echo ""

    local PYTHON_SCRIPT="
from passlib.context import CryptContext
passwd = CryptContext(schemes=['pbkdf2_sha512'])
print(passwd.encrypt('${NEW_PASSWD}'))
"
    local CRYPTED_PASSWD="$(python -c "${PYTHON_SCRIPT}")"

    echo -e "\nUPDATE res_users SET password_crypt = '${CRYPTED_PASSWD}' WHERE id = 1;"
    echo -e " └ \c"
    echo "UPDATE res_users SET password_crypt = '${CRYPTED_PASSWD}' WHERE id = 1;" | psql ${@} -f -
}
function odooMakeDev()
{
    local PYTHON_SCRIPT="
import uuid
print(uuid.uuid4())
"
    local DATABASE_UUID="$(python -c "${PYTHON_SCRIPT}")"
    echo -e "\nUPDATE ir_config_parameter SET value = '${DATABASE_UUID}' WHERE key = 'database.uuid';"
    echo -e " └ \c"
    echo "UPDATE ir_config_parameter SET value = '${DATABASE_UUID}' WHERE key = 'database.uuid';" | psql ${@} -f -

    local DATABASE_SECRET="$(python -c "${PYTHON_SCRIPT}")"
    echo -e "\nUPDATE ir_config_parameter SET value = '${DATABASE_SECRET}' WHERE key = 'database.secret';"
    echo -e " └ \c"
    echo "UPDATE ir_config_parameter SET value = '${DATABASE_SECRET}' WHERE key = 'database.secret';" | psql ${@} -f -

    local MOBILE_UUID="$(python -c "${PYTHON_SCRIPT}")"
    echo -e "\nUPDATE ir_config_parameter SET value = '${MOBILE_UUID}' WHERE key = 'mobile.uuid';"
    echo -e " └ \c"
    echo "UPDATE ir_config_parameter SET value = '${MOBILE_UUID}' WHERE key = 'mobile.uuid';" | psql ${@} -f -

    echo -e "\nDELETE FROM fetchmail_server;"
    echo -e " └ \c"
    echo "DELETE FROM fetchmail_server;" | psql ${@} -f -

    echo -e "\nDELETE FROM ir_cron;"
    echo -e " └ \c"
    echo "DELETE FROM ir_cron;" | psql ${@} -f -

    echo -e "\nDELETE FROM ir_mail_server;"
    echo -e " └ \c"
    echo "DELETE FROM ir_mail_server;" | psql ${@} -f -

    odooChangePassword ${@}
}
function odooRemoveAssets()
{
    echo "DELETE FROM ir_attachment WHERE datas_fname SIMILAR TO '%.(css|js|less)';" | psql ${@} -f -
}

function removeDockerImages()
{
    local IMAGE=${1}
    local SKIP=${2}

    if [ -z "${IMAGE}" ]
    then
        echo "Usage: $(basename "${0}") <repository name> [<# of image to skip> | 1]"
    else
        if [ -z "${SKIP}" ]
        then
            SKIP=1
        fi

        docker images | awk -v IMAGE="${IMAGE}" '{ if (NR > 1 && $1 == IMAGE) print }' | awk -v SKIP=${SKIP} '{ if (NR > SKIP) print $3 }' | xargs docker image rm
    fi
}

function resetPermissions()
{
    local TARGET="${1}"

    if [ -z "${TARGET}" ]
    then
        TARGET="."
    fi

    local REALPATH="$(realpath "${TARGET}")"

    echo -e "\n \033[4;33mWARNING!\033[0m"
    echo -e "  \033[0;33m└\033[0m You are about to reset permissions on all files,"
    echo -e "     directories and subdirectories contained in: \"\033[0;36m${REALPATH}\033[0m\"\n"
    read -p "Are you sure to continue? [N]: " ANSWER

    if [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        echo -e " └ Please, wait... Resetting permissions... \c"

        find "${REALPATH}" -type d -exec chmod 755 {} \;
        find "${REALPATH}" -type f -exec chmod 644 {} \;

        echo -e "\033[0;32mOK!\033[0m"
    else
        echo -e " └ Ok, no problem! Permissions have been left untouched."
    fi
}

function sshTunnel()
{
    if [ ${#} -lt 3 ]
    then
        echo "Usage: $(basename "${0}") <local port> [<ssh username>@]<ssh host>[:<ssh port> | 22] <remote port>"
    else
        local PARTS=($(echo ${2} | tr ':' ' '))
        local SSH_HOST="${PARTS[0]}"
        local SSH_PORT="${PARTS[1]}"

        if [ -z "${SSH_PORT}" ]
        then
            SSH_PORT=22
        fi

        echo -e "\nTunnelling \"localhost:${1}\" to \"${SSH_HOST}:${3}\"..."

        ssh -NL ${1}:localhost:${3} ${SSH_HOST} -p ${SSH_PORT}
    fi
}

function tarCompress()
{
    if [ ${#} -lt 2 ]
    then
        echo "Usage: $(basename "${0}") <archive name> <file or directory to compress>"
    else
        tar -czvf "${1}" "${2}"
    fi
}
function tarExtract()
{
    if [ ${#} -lt 1 ]
    then
        echo "Usage: $(basename "${0}") <archive name> [<directory where extract archive> | .]"
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

    local REALPATH="$(realpath "${TARGET}")"
    REALPATH="${REALPATH#/mnt}"

    echo "${REALPATH}"
}
