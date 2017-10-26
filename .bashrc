#!/usr/bin/env bash

# Functions declarations
#
function addCommitPush()
{
    git add .
    git commit -a -m "${1}"
    git push
}

function pushSetUpstream()
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
    
    git push --set-upstream ${REMOTE} ${BRANCH}
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

    echo -e "\nAre you sure to restore repository from '${REMOTE}/${BRANCH}'?\n"

    echo -e "All your local changes and commits that are not yet"
    echo -e " pushed upstream will be lost forever (it's a long time)!\n"

    read -p "Continue? [Y/N]: " ANSWER

    echo ""

    if [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        git reset --hard ${REMOTE}/${BRANCH}
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
alias merge="git merge"
alias status="git status"

alias add="git add ."
alias commit="git commit -a -m"

alias pull="git pull"
alias push="git push"

# TODO: Creare gli alias per le funzioni di GIT legate ai tag.
