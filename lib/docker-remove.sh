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
                        This will physically remove all
                         matching stopped containers.

    -q / --quiet        Quiet mode.
                        This will only show commands to execute
                         without printing info messages to
                         the user about missing results.

    -h / -? / --help    Prints this help message."

    local IMAGES=()

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            -c | --commit)
                local COMMIT="--commit"
                ;;
            -q | --quiet)
                local QUIET="--quiet"
                ;;
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -*)
                echo "[ERROR] Unknown option: '${1}'"
                echo "        Try \"docker-remove-stopped-containers --help\" for more information."

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

            if [[ ${#IMAGE_CONTAINERS[@]} -gt 0 ]]
            then
                CONTAINERS_TO_REMOVE+=(${IMAGE_CONTAINERS[@]})

            elif [[ -z "${QUIET}" ]]
            then
                echo "[INFO] There are no stopped container using the '${IMAGE}' image."
            fi
        done
    else
        CONTAINERS_TO_REMOVE=($(echo "${STOPPED_CONTAINERS}" | awk '{ print $1 }'))
    fi

    if [[ ${#CONTAINERS_TO_REMOVE[@]} -eq 0 ]]
    then
        if [[ -z "${QUIET}" ]]
        then
            echo "[INFO] There are no stopped containers to remove."
        fi

        return -1
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

    -q / --quiet        Quiet mode.
                        This will only show commands to execute
                         without printing info messages to
                         the user about missing results.

    -s / --skip <INT>    Skips the removal of the latest <INT> more recent images.
                         This is useful when you want to keep some of the latest images.
                         By default, when this option isn't specified, the default <INT>
                          value is 1 keeping the last most recent image.
                         If you're not interested in keeping any
                          of the images, you can use the value 0.

    -u / --untagged      Removes all the images that are no longer tagged.
                         When you download from the registry or locally build a
                          new version of a specific image, Docker removes the used
                          tag from the previous image and assigns it to the new one.
                         This causes the old image to become an untagged one.
                         When using this option, you can either specify registries
                          to remove the images from or omit them altogether to
                          remove all untagged images available on the system.
                         Also, when this option is used, the '--skip' value
                          is automatically set to 0; you can still specify
                          it by using the '--skip' option explicitly.

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
            -q | --quiet)
                local QUIET="--quiet"
                ;;
            -s | --skip)
                if [[ ! "${2}" =~ ^[0-9]+$ ]]
                then
                    echo "[ERROR] The '${1}' option requires an integer value."
                    echo "        Try \"docker-remove-images --help\" for more information."

                    return 2
                fi

                local SKIP="${2}"

                shift
                ;;
            -u | --untagged)
                local UNTAGGED="--untagged"
                ;;
            -h | -? | --help)
                echo "${HELP}"

                return 0
                ;;
            -*)
                echo "[ERROR] Unknown option: '${1}'"
                echo "        Try \"docker-remove-images --help\" for more information."

                return 1
                ;;
            *)
                REPOSITORIES+=("${1}")
                ;;
        esac

        shift
    done

    if [[ -z "${SKIP}" ]]
    then
        if [[ -n "${UNTAGGED}" ]]
        then
            local SKIP="0"
        else
            local SKIP="1"
        fi
    fi

    local IMAGES_TO_REMOVE=()

    if [[ ${#REPOSITORIES[@]} -gt 0 ]]
    then
        if [[ -n "${UNTAGGED}" ]]
        then
            for REPOSITORY in ${REPOSITORIES[@]}
            do
                local IMAGES=("$(docker images | awk '{ if (NR > 1 && $1 == "'"${REPOSITORY}"'") print }')")
                IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > '${SKIP}' && $2 == "<none>") print $3 }')")

                if [[ ${#IMAGES[@]} -gt 0 ]]
                then
                    IMAGES_TO_REMOVE+=(${IMAGES[@]})

                elif [[ -z "${QUIET}" ]]
                then
                    echo "[INFO] There are no untagged images to remove for the '${REPOSITORY}' repository."
                fi
            done
        else
            for REPOSITORY in ${REPOSITORIES[@]}
            do
                local IMAGES=("$(docker images | awk '{ if (NR > 1 && $1 == "'"${REPOSITORY}"'") print }')")
                IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > '${SKIP}') { if ($2 != "<none>") { print $1":"$2 } else { print $3 } } }')")

                if [[ ${#IMAGES[@]} -gt 0 ]]
                then
                    IMAGES_TO_REMOVE+=(${IMAGES[@]})

                elif [[ -z "${QUIET}" ]]
                then
                    echo "[INFO] There are no images to remove for the '${REPOSITORY}' repository."
                fi
            done
        fi
    elif [[ -n "${UNTAGGED}" ]]
    then
        local IMAGES=("$(docker images | awk '{ if (NR > 1) print }')")
        IMAGES=("$(echo "${IMAGES[@]}" | awk '{ if (NR > '${SKIP}' && $2 == "<none>") print $3 }')")

        if [[ ${#IMAGES[@]} -gt 0 ]]
        then
            IMAGES_TO_REMOVE+=(${IMAGES[@]})

        elif [[ -z "${QUIET}" ]]
        then
            echo "[INFO] There are no untagged images to remove."
        fi
    else
        echo "[ERROR] No repositories specified."
        echo "        Try \"docker-remove-images --help\" for more information."

        return 3
    fi

    if [[ ${#IMAGES_TO_REMOVE[@]} -eq 0 ]]
    then
        if [[ -z "${QUIET}" ]]
        then
            echo "[INFO] There are no images to remove."
        fi

        return -1
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
            docker-remove-stopped-containers "${COMMIT}" --quiet "${IMAGE}"

            ${COMMAND} "${IMAGE}"
        done
    else
        echo ${IMAGES_TO_REMOVE[@]} | xargs -n 1 ${COMMAND}
    fi
}
