#!/usr/bin/env bash
#
# `~/.bashrc`: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files
#  (in the package bash-doc) for examples.
#

#
# If not running interactively, don't do anything
#
case $- in
    *i*) ;;
      *) return;;
esac

#
# History Management:
#  - don't put duplicate lines
#  - don't put lines with leading spaces
#
HISTCONTROL=ignorespace:ignoredups

#  - append to the history file, don't overwrite it
#  - check the window size after each command and, if necessary,
#     update the values of LINES and COLUMNS.
#
shopt -s histappend
shopt -s checkwinsize

#  - setting history length
#
HISTSIZE=-1
HISTFILESIZE=-1

#  - saving and reloading the history after each command finishes
#
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#
# If set, the pattern "**" used in a pathname expansion context will
#  match all files and zero or more directories and subdirectories.
#
# shopt -s globstar

#
# Make less more friendly for non-text input files, see lesspipe(1)
#
if [[ -x "/usr/bin/lesspipe" ]]
then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

#
# Useful export (if you're under WSL)
#
if [[ -x "/bin/wslpath" ]]
then
    export IS_WSL_ENV=1

    #
    # Useful WSL settings
    #
    umask 022
fi

#
# Alias definitions.
# You may want to put all your additions into a separate file
#  like `~/.bash_aliases`, instead of adding them here directly.
# See `/usr/share/doc/bash-doc/examples` in the bash-doc package.
#
if [[ -f ~/.bash_aliases ]]
then
    source ~/.bash_aliases
fi
if [[ -f ~/.bash_customs ]]
then
    source ~/.bash_customs
fi
if [[ -f ~/.bash_exports ]]
then
    source ~/.bash_exports
fi
if [[ -f ~/.bash_functions ]]
then
    source ~/.bash_functions
fi

#
# Print a random phrase when the terminal is
#  opened and all scripts have been loaded.
#
_random-phrase
