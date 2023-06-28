#!/usr/bin/env bash
#

function __access-docker-moby-linux-vm()
{
    echo -e "\n \e[4;33mWARNING!\e[0m"
    echo -e "  \e[33m├\e[0m You're about to directly access the Docker MobyLinuxVM..."
    echo -e "  \e[33m│\e[0m"
    echo -e "  \e[33m└\e[0m Please, continue at your own risk only"
    echo -e "     if you know \e[4mEXACTLY\e[0m what you're doing.\n"

    read -p "Are you sure to continue? [N]: " ANSWER

    if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]
    then
        echo -e " └ Ok, then... Pay attention from now on!\n"

        docker run -it --rm \
                    --privileged \
                \
                --name "moby" \
                --security-opt "seccomp=unconfined" \
                \
                --ipc "host" \
                --net "host" \
                --pid "host" \
                --uts "host" \
                \
                -v "/":"/moby" \
            \
            "alpine":"latest" "chroot" "/moby"
    else
        echo -e " └ Never mind... See ya' next time."
    fi
}

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

function _random-phrase()
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

function clean()
{
    clear

    _random-phrase
}

function ip-address()
{
    if [[ -z "$(which ifconfig)" ]]
    then
        echo -e "\n \e[4;31mERROR!\e[0m"
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

function kube-dashboard()
{
    local ADMIN_NAMESPACE="kube-system"
    local ADMIN_NAME="admin-user"
    local DASHBOARD_NAMESPACE="kubernetes-dashboard"
    local DASHBOARD_SERVICE="kubernetes-dashboard"

    local SECRET_NAME="$(kubectl -n "${ADMIN_NAMESPACE}" get secret | grep "^${ADMIN_NAME}-token-" | awk '{print $1}')"
    local SECRET_TOKEN="$(kubectl -n "${ADMIN_NAMESPACE}" describe secret "${SECRET_NAME}" | grep "^token: " | awk '{print $2}')"

    echo -e "\nKubernetes dashboard is starting..."
    echo " │"
    echo -e " ├ URL: \e[4;36mhttp://localhost:8001/api/v1/namespaces/${DASHBOARD_NAMESPACE}/services/https:${DASHBOARD_SERVICE}:/proxy/\e[0m"
    echo " │"
    echo -e " └ Token: ${SECRET_TOKEN}\n"

    kubectl proxy
}

function permissions-reset()
{
    local TARGET="${1}"

    if [[ -z "${TARGET}" ]]
    then
        TARGET="."
    fi

    local REALPATH="$(realpath "${TARGET}")"

    echo -e "\n \e[4;33mWARNING!\e[0m"
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
    else
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
    fi
}

function serve-dir()
{
    local PORT="${1}"

    if [[ "${PORT}" == "-h" ]] || [[ "${PORT}" == "--help" ]]
    then
        echo "Usage: serve-dir [<local port> | 8000]"
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
    else
        local PARTS=($(echo ${2} | tr ':' ' '))
        local SSH_HOST="${PARTS[0]}"
        local SSH_PORT="${PARTS[1]}"

        if [[ -z "${SSH_PORT}" ]]
        then
            SSH_PORT=22
        fi

        echo -e "\nTunnelling \"localhost:${1}\" to \"${SSH_HOST}:${3}\"..."

        ssh -NL ${1}:localhost:${3} ${SSH_HOST} -p ${SSH_PORT}
    fi
}

function tar-compress()
{
    if [[ ${#} -lt 2 ]]
    then
        echo "Usage: tar-compress <archive name> <file or directory to compress>"
    else
        tar -czvf "${1}" "${2}"
    fi
}
function tar-extract()
{
    if [[ ${#} -lt 1 ]]
    then
        echo "Usage: tar-extract <archive name> [<directory where extract archive> | .]"
    else
        local EXTRACT_PATH="${2}"

        if [[ -z "${EXTRACT_PATH}" ]]
        then
            EXTRACT_PATH="."
        fi

        tar -xzvf "${1}" -C "${EXTRACT_PATH}"
    fi
}

function weather()
{
    local LOCATION="${1}"

    curl "https://wttr.in/${LOCATION}"
}

#
# Imported from external files
#
source ./functions/docker-remove.sh
source ./functions/odoo.sh

#
# Useful functions (if you're under WSL)
#
function wsl-host-ip()
{
    cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'
}
