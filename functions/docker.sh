#!/usr/bin/env bash
#

function docker-remove-stopped-containers()
{
    local HELP="
Removes all the stopped containers at once.

By default, it runs in 'dry mode' and will only show a list of commands to run.
You can copy 'n paste it or just run this command using the '--commit' option.

Usage:
    docker-remove-stopped-containers [OPTIONS...]

Options:
    -c / --commit    Runs in 'commit mode'.
                     This will remove all the stopped containers."

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -c | --commit)
                local COMMIT="true"
                ;;
            *)
                echo "Error: unknown option '${1}'"
                echo "Try \"terminateDatabaseConnections --help\" for more information."

                return -1
                ;;
        esac

        shift
    done

    local CONTAINERS=($(docker ps -a | grep " Exited " | awk '{ print $1 }'))

    if [[ -z "${CONTAINERS}" ]]
    then
        echo "There are no containers to remove."

        return 0
    fi

    local COMMAND="docker rm"

    if [[ -z "${COMMIT}" ]]
    then
        local COMMAND="echo ${COMMAND}"
    fi

    echo "${CONTAINERS[@]}" | xargs -n 1 ${COMMAND}
}

function docker-remove-images()
{
    local HELP="
Removes all the stopped containers at once.
By default, it runs in 'dry mode' and will only show a list of commands to run.

Usage:
    docker-remove-images REPOSITORY | WORKING_MODE [SKIP | 1] [OPTIONS...]

Args:
    REPOSITORY           The name of the repository ...
    SKIP                 A number ...
                         default: 1

Working modes:
    --untagged           '<none>'
    --all                All the images.

Options:
    -c / --commit    Runs in 'commit mode'.
                     This will fisically remove all the matching containers.

    -f / --force     Forces ..."

    local ARGS=()

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            --untagged)
                local UNTAGGED="true"
                ;;
            --all)
                echo "Not implemented yet."

                return -992
                ;;
            -c | --commit)
                local COMMIT="true"
                ;;
            -f | --force)
                echo "Not implemented yet."

                return -994
                ;;
            *)
                ARGS+=("${1}")
                ;;
        esac

        shift
    done

    set -- "${ARGS[@]}"

    # if [[ "${FORCE}" == "true" ]]
    # then
    #     removeStoppedContainers
    # fi

    local IMAGE="${1}"
    local SKIP="${2}"

    if [[ -z "${IMAGE}" ]]
    then
        echo "${HELP}"

        return 0
    fi

    if [[ -z "${SKIP}" ]]
    then
        if [[ -n "${UNTAGGED}" ]]
        then
            local SKIP=0
        else
            local SKIP=1
        fi
    fi

    local IMAGES=($(docker images | awk '{ if (NR > 1 && $1 == "'"${IMAGE}"'") print }' | awk '{ if (NR > '"${SKIP}"') print $3 }'))

    if [[ -z "${IMAGES}" ]]
    then
        echo "There are no images to remove."

        return 0
    fi
    
    local COMMAND="docker image rm"

    if [[ -z "${COMMIT}" ]]
    then
        local COMMAND="echo ${COMMAND}"
    fi

    echo "${IMAGES[@]}" | xargs -n 1 ${COMMAND}
}







function removeUntaggedDockerImages()
{
    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -f | --force)
                local FORCE="--force"
                ;;
            *)
                ;;
        esac

        shift
    done

    removeDockerImages "<none>" 0 "${FORCE}"
}
function removeAllDockerImages()
{
    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -f | --force)
                local FORCE="--force"
                ;;
            *)
                ;;
        esac

        shift
    done

    removeUntaggedDockerImages "${FORCE}"

    local IMAGES=($(docker images | awk '{ if (NR > 1) print $1 }' | sort | uniq -c | awk '{ if ($1 > 1) print $2 }'))

    if [[ -n "${IMAGES}" ]]
    then
        for IMAGE in ${IMAGES}
        do
            removeDockerImages "${IMAGE}" "${FORCE}"
        done
    else
        echo -e "\nThere are no images to remove."
    fi
}

