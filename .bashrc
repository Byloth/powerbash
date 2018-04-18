#!/usr/bin/env bash
#
# ~/.bashrc: executed by bash(1) for non-login shells.
#

#
# If not running interactively, don't do anything.
#
case $- in
    *i*) ;;
      *) return;;
esac

#
# History Management:
#
#  - don't put duplicate lines and erase duplicate lines:
#
HISTCONTROL=ignoredups:erasedups

#  - append to the history file, don't overwrite it:
#
shopt -s histappend

#  - setting history length:
#
HISTSIZE=100000
HISTFILESIZE=100000

#  - saving and reloading the history after each command finishes:
#
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#
# Defining the default editor to use.s
#
VISUAL="nano"
EDITOR="${VISUAL}"


if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_customs ]; then
    . ~/.bash_customs
fi

if [ -f ~/.bash_powergit ]; then
    . ~/.bash_powergit
fi
