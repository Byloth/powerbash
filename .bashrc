#!/usr/bin/env bash

# Functions declarations
#
function addCommitPush()
{
    git add .
    git commit -a -m "${1}"
    git push
}

function getRemoteBranch()
{
    if [ -n "${1}" ]
    then
        if [ -n "${2}" ]
        then
            REMOTE="${1}"
            BRANCH="${2}"
        else
            REMOTE="origin"
            BRANCH="${1}"
        fi
    else
        REMOTE="origin"
        BRANCH="master"
    fi

    if [ -n "${3}" ]
    then
        SEPARATOR="${3}"
    else
        SEPARATOR=" "
    fi

    echo "${REMOTE}${SEPARATOR}${BRANCH}"
}

function pushSetUpstream()
{
    BRANCH=$(getRemoteBranch "${1}" "${2}")
    
    git push --set-upstream ${BRANCH}
}

function reset()
{
    echo -e "\nAre you sure to restore repository to the last commit?"
    echo -e "All your local changes will be lost forever (it's a long time)!\n"

    read -p "Continue? [Y/N]: " ANSWER

    echo ""

    if [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        git reset --hard
    else
        echo -e "Repository has been left untouched."
    fi
}
function resetByUpstream()
{
    git fetch --all

    BRANCH=$(getRemoteBranch "${1}" "${2}" "/")

    echo -e "\nAre you sure to restore repository from '${BRANCH}'?\n"

    echo -e "All your local changes and commits that are not yet"
    echo -e " pushed upstream will be lost forever (it's a long time)!\n"

    read -p "Continue? [Y/N]: " ANSWER

    echo ""

    if [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        git reset --hard ${BRANCH}
    else
        echo -e "Repository has been left untouched."
    fi
}

# Functions aliases
#
alias push-commit=addCommitPush
alias push-new-branch=pushSetUpstream

alias restore=reset
alias remote-restore=resetByUpstream

# GIT commands aliases
#
alias init="git init"
alias clone="git clone"
alias fetch="git fetch --all"

alias master="git checkout master"

alias branch="git checkout"
alias new-branch="git checkout -B"

alias compare="git diff"
alias count-commit="git rev-list --count --first-parent HEAD"
alias merge="git merge"
alias status="git status"

alias add="git add ."
alias commit="git commit -a -m"
alias edit-commit="git commit --amend"

alias pull="git pull"
alias push="git push"

# TODO: Creare gli alias per le funzioni di GIT legate ai tag.
