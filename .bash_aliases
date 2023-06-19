#!/usr/bin/env bash
#

#
# Enable color support of 'ls', 'grep'
#  and also add handy aliases
#
if [[ -x "/usr/bin/dircolors" ]]
then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls="ls --color=auto"
    alias dir="dir --color=auto"
    alias vdir="vdir --color=auto"

    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
fi

#
# Some more "ls" aliases
#
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

#
# Useful aliases
#
if [[ -x "/usr/bin/batcat" ]]
then
    alias cat="batcat"
fi
if [[ -x "/usr/bin/github-copilot-cli" ]]
then
    eval "$(github-copilot-cli alias -- "${0}")"
fi

#
# Useful proxy aliases
#
# alias sudo="sudo --preserve-env"

#
# Useful WSL aliases
#
if [[ -n "${IS_WSL_ENV}" ]]
then
    alias su="sudo su"
fi

#
# User defined aliases
#
alias home="cd && clean"
alias welcome="tmux new-session 'htop' \; rename-window workspace \; split-window -p 85 \; split-window -d -p 40 \; split-window -h \; swap-pane -D \; select-pane -U"
