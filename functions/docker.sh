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
    -c / --commit       Runs in 'commit mode'.
                        This will remove all the stopped containers.

    -h / -? / --help    Shows this help message."

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
                echo "Try \"docker-remove-stopped-containers --help\" for more information."

                return -1
                ;;
        esac

        shift
    done

    local CONTAINERS=("$(docker ps -a | grep " Exited " | awk '{ print $1 }')")

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
    docker-remove-images [OPTIONS...] REPOSITORY [REPOSITORIES...]

Arguments:
    REPOSITORY           The name of the repository ...

General options:
    -c / --commit         Runs in 'commit mode'.
                          This will fisically remove all the matching containers.

    -f / --force          Forces ...
    -s / --skip INT       Skips a number of images.
                          default: 1

    -h / -? / --help      Shows this help message.

Working mode options:
    --untagged           '<none>'
    --all                All the images."

    local REPOSITORIES=()

    if [[ ${#} -eq 0 ]]
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
            -s | --skip)
                local SKIP="${2}"

                shift
                ;;
            *)
                REPOSITORIES+=("${1}")
                ;;
        esac

        shift
    done

    # if [[ "${FORCE}" == "true" ]]
    # then
    #     removeStoppedContainers
    # fi

    if [[ -z "${REPOSITORIES}" ]]
    then
        echo "Error: no repositories specified."
        echo "Try \"docker-remove-images --help\" for more information."

        return -1
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

    set -- "${REPOSITORIES[@]}"

    while [[ ${#} -gt 0 ]]
    do
        local REPOSITORY="${1}"

        local IMAGES=("$(docker images | awk '{ if (NR > 1 && $1 == "'"${REPOSITORY}"'") print }')")

        if [[ -n "${UNTAGGED}" ]]
        then
            local IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if ($2 == "'"<none>"'") print }')")
        fi

        local IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > "'"${SKIP}"'") print $3 }')")

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

        shift
    done
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

