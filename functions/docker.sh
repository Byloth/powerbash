#!/usr/bin/env bash
#

function docker-remove-stopped-containers()
{
    local HELP="
Removes all the stopped containers at once.

By default, it runs in 'dry mode' and will only show a list of commands to run.
You can copy 'n paste it or just run this command using the '--commit' option.

Usage:
    docker-remove-stopped-containers [OPTIONS...] IMAGE [IMAGES...]

Arguments:
    IMAGE               The name of the Docker image(s) still attached
                         to the stopped containers you wat to remove.
                        Specify one or more images will allows you to remove
                         only containers that use the specified image(s).

Options:
    -c / --commit       Runs in 'commit mode'.
                        This will remove all the stopped containers.

    -h / -? / --help    Prints this help message."

    local IMAGES=()

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -c | --commit)
                local COMMIT="true"
                ;;
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -*)
                echo "Error: unknown option '${1}'"
                echo "Try \"docker-remove-stopped-containers --help\" for more information."

                return 1
                ;;
            *)
                IMAGES+=("${1}")
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
Removes all the older images from all the specified repositories at once.

By default, it runs in 'dry mode' and will only show a list of commands to run.
You can copy 'n paste it or just run this command using the '--commit' option.

Usage:
    docker-remove-images [OPTIONS...] REPOSITORY [REPOSITORIES...]

Arguments:
    REPOSITORY           The name of the repository(s) whose
                          images you want to remove.

Options:
    -c / --commit        Runs in 'commit mode'.
                         This will fisically remove all the matching images.

    -f / --force         Forces the removal of all the stopped containers
                          where the images to be removed are still in use.

    -s / --skip <INT>    Skips the removal of the latest <INT> more recent images.
                         This is useful when you want to keep some of the latest images.
                         By default, when this option isn't specified, the default <INT>
                          value is 1 keeping the last most recent image.
                         If you're not interested in keeping any of
                         of the images, you can use the value 0.

    -h / -? / --help     Prints this help message."

    local REPOSITORIES=()

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
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
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -*)
                echo "Error: unknown option '${1}'"
                echo "Try \"docker-remove-images --help\" for more information."

                return 1
                ;;
            *)
                REPOSITORIES+=("${1}")
                ;;
        esac

        shift
    done

    if [[ -z "${REPOSITORIES}" ]]
    then
        echo "Error: no repositories specified."
        echo "Try \"docker-remove-images --help\" for more information."

        return 2
    fi
    if [[ -z "${SKIP}" ]]
    then
        local SKIP="1"
    fi

    set -- "${REPOSITORIES[@]}"

    while [[ ${#} -gt 0 ]]
    do
        local REPOSITORY="${1}"

        local IMAGES=("$(docker images | awk '{ if (NR > 1 && $1 == "'"${REPOSITORY}"'") print }')")
        local IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > "'"${SKIP}"'") print $3 }')")

        if [[ -z "${IMAGES}" ]] && [[ -n "${COMMIT}" ]]
        then
            echo "There are no images to remove for repository: '${REPOSITORY}'."

            continue
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

