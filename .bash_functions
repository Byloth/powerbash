#!/usr/bin/env bash
#

function _get-pgpassword()
{
    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -U | --username)
                PGUSER="${2}"

                shift
                ;;
            -w | --no-password)
                NO_PASSWORD="true"
                ;;
        esac

        shift
    done

    if [[ -z "${PGPASSWORD}" ]] && [[ -z "${NO_PASSWORD}" ]]
    then
        echo ""
        read -s -p "PostgreSQL password for user \"${PGUSER}\": " PGPASSWORD
        echo ""

        export PGPASSWORD
    fi
}
function _psql-query()
{
    _get-pgpassword "${@}"

    local QUERY="${1}"

    echo -e "\n${QUERY}"
    echo -e " └ \c"
    echo "${QUERY}" | psql "${@:2}" -f -
}

function cowsay-fortune()
{
    #
    # Some other "cows" here: /usr/share/cowsay/cows
    #  -f <cow_name>
    #  -W <max_columns>
    #  -b / -d / -g / -p / -s / -t / -w / -y
    #
    local COW_PARAMS="-bdgpstwy"

    fortune -as | cowthink -n -${COW_PARAMS:$(shuf -i0-8 -n1):1}
}

function base64-encode()
{
    echo -n "${1}" | base64
}
function base64-decode()
{
    echo -n "${1}" | base64 --decode
}

function ip-address()
{
    if [[ -z "$(which ifconfig)" ]]
    then
        echo -e "\n \e[31;4mERROR!\e[0m"
        echo -e "  \e[31m├\e[0m This command requires \"\e[36mifconfig\e[0m\" to be"
        echo -e "  \e[31m│\e[0m  available on your system to work properly."
        echo -e "  \e[31m│\e[0m"
        echo -e "  \e[31m└\e[0m You can install it by running:"
        echo -e "     └ \e[1;4msudo apt install net-tools\e[0m"

        return 1
    fi

    local NAMES=($(ifconfig | grep -E "^\w+: " | awk '{ print $1 }'))
    local ADDRESSES=($(ifconfig | grep "inet " | awk '{ print $2 }'))

    for I in "${!NAMES[@]}"
    do
        local NAME="${NAMES[$I]}"
        local ADDRESS="${ADDRESSES[$I]}"

        if [[ "${ADDRESS}" != "127.0.0.1" ]]
        then
            echo -e "${NAME}\t${ADDRESS}"
        fi
    done
}

function permissions-reset()
{
    local TARGET="${1}"

    if [[ -z "${TARGET}" ]]
    then
        TARGET="."
    fi

    local REALPATH="$(realpath "${TARGET}")"

    echo -e "\n \e[33;4mWARNING!\e[0m"
    echo -e "  \e[33m└\e[0m You are about to reset permissions on all files,"
    echo -e "     directories and subdirectories contained in: \"\e[36m${REALPATH}\e[0m\"\n"
    read -p "Are you sure to continue? [N]: " ANSWER

    if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]
    then
        echo -e " └ Please, wait... Resetting permissions... \c"

        find "${REALPATH}" -type d -exec chmod 755 {} \;
        find "${REALPATH}" -type f -exec chmod 644 {} \;

        echo -e "\e[32mOK!\e[0m"
    else
        echo -e " └ Ok, no problem! Permissions have been left untouched."
    fi
}

function pgdatabase-close-connections()
{
    local HELP="Usage: pgdatabase-close-connections -d | --database <database name>"

    if [[ ${#} -lt 1 ]]
    then
        echo "${HELP}"

        return 0
    fi

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -d | --database)
                PGDATABASE="${2}"

                shift
                ;;
            *)
                echo "Error: unknown option '${1}'"
                echo "Try \"pgdatabase-close-connections --help\" for more information."

                return -1
                ;;
        esac

        shift
    done

    _psql-query "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${PGDATABASE}' AND pid <> pg_backend_pid();" -d postgres
}

function serve-dir()
{
    local PORT="${1}"

    if [[ "${PORT}" == "-h" ]] || [[ "${PORT}" == "--help" ]]
    then
        echo "Usage: serve-dir [<local port> | 8000]"

        return 0
    elif [[ -z "${PORT}" ]]
    then
        PORT=8000
    fi

    python3 -m http.server "${PORT}"
}

function ssh-tunnel()
{
    if [[ ${#} -lt 3 ]]
    then
        echo "Usage: ssh-tunnel <local port> [<ssh username>@]<ssh host>[:<ssh port> | 22] <remote port>"

        return 0
    fi

    local PARTS=($(echo ${2} | tr ':' ' '))
    local SSH_HOST="${PARTS[0]}"
    local SSH_PORT="${PARTS[1]}"

    if [[ -z "${SSH_PORT}" ]]
    then
        SSH_PORT=22
    fi

    echo -e "\nTunnelling \"localhost:${1}\" to \"${SSH_HOST}:${3}\"..."

    ssh -NL ${1}:localhost:${3} ${SSH_HOST} -p ${SSH_PORT}
}

function tar-compress()
{
    if [[ ${#} -lt 2 ]]
    then
        echo "Usage: tar-compress <archive name> <file or directory to compress>"

        return 0
    fi

    tar -czvf "${1}" "${2}"
}
function tar-extract()
{
    if [[ ${#} -lt 1 ]]
    then
        echo "Usage: tar-extract <archive name> [<directory where extract archive> | .]"

        return 0
    fi

    local EXTRACT_PATH="${2}"

    if [[ -z "${EXTRACT_PATH}" ]]
    then
        EXTRACT_PATH="."
    fi

    tar -xzvf "${1}" -C "${EXTRACT_PATH}"
}

function weather()
{
    if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]
    then
        echo "Usage: weather [<location>]"

        return 0
    fi

    local LOCATION="${1}"

    curl "https://wttr.in/${LOCATION}"
}

#
# Imported from external files
#
source ./functions/docker-remove.sh

#
# Useful functions (if you're under WSL)
#
function wsl-host-ip()
{
    cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'
}
