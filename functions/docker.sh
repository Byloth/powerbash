#!/usr/bin/env bash
#

function docker-remove-stopped-containers()
{
    local HELP="
Removes all the stopped containers at once.

By default, it runs in 'dry mode' and will only show a list of commands to run.
You can copy 'n paste it or just run this command using the '--commit' option.

Usage:
    docker-remove-stopped-containers [OPTIONS...] [IMAGE] [IMAGES...]

Arguments:
    IMAGE               The name of the Docker image(s) still attached
                         to the stopped containers you want to remove.
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

    local CONTAINERS_TO_REMOVE=()
    local STOPPED_CONTAINERS="$(docker ps -a | grep " Exited (")"

    if [[ ${#IMAGES[@]} -gt 0 ]]
    then
        for IMAGE in ${IMAGES[@]}
        do
            local IMAGE_CONTAINERS=($(echo "${STOPPED_CONTAINERS}" | awk '{ if ($2 == "'"${IMAGE}"'") print $1 }'))

            if [[ ${#IMAGE_CONTAINERS[@]} -eq 0 ]]
            then
                echo "Error: unable to find any stopped container using image '${IMAGE}'"
                echo "Try \"docker-remove-stopped-containers --help\" for more information."

                return 2
            fi

            CONTAINERS_TO_REMOVE+=(${IMAGE_CONTAINERS[@]})
        done
    else
        CONTAINERS_TO_REMOVE=($(echo "${STOPPED_CONTAINERS}" | awk '{ print $1 }'))
    fi

    if [[ ${#CONTAINERS_TO_REMOVE[@]} -eq 0 ]]
    then
        echo "Info: there are no stopped containers to remove."

        return 0
    fi

    local COMMAND="docker rm"

    if [[ -z "${COMMIT}" ]]
    then
        COMMAND="echo ${COMMAND}"
    fi

    echo ${CONTAINERS_TO_REMOVE[@]} | xargs -n 1 ${COMMAND}
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
                local COMMIT="--commit"
                ;;
            -f | --force)
                local FORCE="--force"
                ;;
            -s | --skip)
                if [[ ! "${2}" =~ ^[0-9]+$ ]]
                then
                    echo "Error: the '${1}' option requires an integer value."
                    echo "Try \"docker-remove-images --help\" for more information."

                    return 2
                fi

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

    if [[ ${#REPOSITORIES[@]} -eq 0 ]]
    then
        echo "Error: no repositories specified."
        echo "Try \"docker-remove-images --help\" for more information."

        return 3
    fi
    if [[ -z "${SKIP}" ]]
    then
        local SKIP="1"
    fi

    local IMAGES_TO_REMOVE=()

    for REPOSITORY in ${REPOSITORIES[@]}
    do
        local IMAGES=("$(docker images | awk '{ if (NR > 1 && $1 == "'"${REPOSITORY}"'") print }')")
        IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > '${SKIP}') { if ($1 != "<none>" && $2 != "<none>") { print $1":"$2 } else { print $3 } } }')")

        if [[ -z "${IMAGES}" ]] && [[ -n "${COMMIT}" ]]
        then
            echo "Info: there are no images to remove for repository: '${REPOSITORY}'."

            continue
        fi

        IMAGES_TO_REMOVE+=(${IMAGES[@]})
    done

    if [[ ${#IMAGES_TO_REMOVE[@]} -eq 0 ]]
    then
        echo "Info: there are no images to remove."

        return 0
    fi
        
    local COMMAND="docker image rm"

    if [[ -z "${COMMIT}" ]]
    then
        local COMMAND="echo ${COMMAND}"
    fi

    if [[ -n "${FORCE}" ]]
    then
        for IMAGE in ${IMAGES_TO_REMOVE[@]}
        do
            docker-remove-stopped-containers "${COMMIT}" "${IMAGE}"
        done

        ${COMMAND} "${IMAGE}"
    else
        echo ${IMAGES_TO_REMOVE[@]} | xargs -n 1 ${COMMAND}
    fi
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

