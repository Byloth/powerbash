#!/usr/bin/env bash
#

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines and erase duplicate lines.
# See bash(1) for more options
#
HISTCONTROL=ignoredups:erasedups

# append to the history file, don't overwrite it
#
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#
HISTSIZE=100000
HISTFILESIZE=100000

# Save and reload the history after each command finishes
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
#
shopt -s checkwinsize

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_customs ]; then
    . ~/.bash_customs
fi

VISUAL="nano"
EDITOR="${VISUAL}"

if [ -f ~/.bash_powergit ]; then
    . ~/.bash_powergit
fi
