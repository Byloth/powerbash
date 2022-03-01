#!/usr/bin/env bash
#

#
# Enable color support of 'ls', 'grep'
#  and also add handy aliases
#
if [[ -x /usr/bin/dircolors ]]
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
if [[ -x /usr/bin/bat ]]
then
    alias cat="bat"
fi

#
# Useful WSL aliases
#
if [[ -n "${IS_WSL_ENV}" ]]
then
    alias su="sudo su"
fi

#
# Other extra aliases
#
alias home="cd && clean"
alias welcome="tmux new-session 'htop' \; rename-window workspace \; split-window -p 85 \; split-window -d -p 40 \; split-window -h \; swap-pane -D \; select-pane -U"
